import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p; // Alias 'p' biar gak bentrok
import 'package:prism/controller/bluesky_controller.dart';
import 'package:prism/controller/twitter_controller.dart';

class ThePrismController {
  final TwitterController _twitter = TwitterController();
  final BlueskyController _bsky = BlueskyController();

  // Status Login (Cache)
  bool _isTwitterReady = false;
  bool _isBskyReady = false;

  // 1. INIT
  Future<void> init() async {
    _isTwitterReady = await _twitter.init();
    _isBskyReady = await _bsky.init();
    print("Prism Status -> Twitter: $_isTwitterReady, Bluesky: $_isBskyReady");
  }

  // --- FUNGSI UTAMA: BROADCAST ---
  Future<String> broadcast(String text, List<File> images) async {
    await init();

    if (!_isTwitterReady && !_isBskyReady) {
      return "Anda belum login ke akun manapun!";
    }

    List<String> reports = [];

    // --- A. LOGIKA TWITTER (Upload Original / GIF logic ada di dalam controller) ---
    if (_isTwitterReady) {
      String result;
      if (images.isNotEmpty) {
        result = await _twitter.postTweetWithImages(text, images);
      } else {
        result = await _twitter.postTweet(text);
      }
      reports.add("X: $result");
    }

    // --- B. LOGIKA BLUESKY (Dengan Kompresi Khusus) ---
    if (_isBskyReady) {
      String result;
      if (images.isNotEmpty) {
        // [UPDATE] Kompres dulu sebelum dikirim ke Bluesky
        List<File> bskyImages = await _compressForBluesky(images);
        
        // Kirim gambar yang sudah dikompres
        result = await _bsky.postImage(text, bskyImages);
      } else {
        result = await _bsky.postFeed(text);
      }
      reports.add("BSKY: $result");
    }

    return reports.join("\n");
  }

  // --- HELPER: KOMPRESI GAMBAR KHUSUS BLUESKY ---
  Future<List<File>> _compressForBluesky(List<File> originals) async {
    List<File> processedFiles = [];

    for (var file in originals) {
      int sizeInBytes = await file.length();
      double sizeInMb = sizeInBytes / (1024 * 1024);

      // Logika: Jika file > 900KB (0.9 MB), kita kompres.
      // Bluesky limitnya sekitar 1MB, jadi 0.9 aman.
      if (sizeInMb > 0.9) {
        print("Mengompres gambar untuk Bluesky: ${p.basename(file.path)} (${sizeInMb.toStringAsFixed(2)} MB)");
        
        final compressedFile = await _compressFile(file);
        
        if (compressedFile != null) {
          processedFiles.add(compressedFile);
        } else {
          // Kalau gagal kompres, paksa pakai file asli (berdoa semoga lolos)
          processedFiles.add(file);
        }
      } else {
        // File sudah kecil, langsung pakai
        processedFiles.add(file);
      }
    }
    return processedFiles;
  }

  // Logika Teknis Kompresi
  Future<File?> _compressFile(File file) async {
    try {
      final filePath = file.absolute.path;
      
      // Bikin nama file baru: "foto.jpg" -> "foto_compressed.jpg"
      // Kita perlu output path yang beda supaya tidak menimpa file asli user
      final lastIndex = filePath.lastIndexOf(RegExp(r'.jp|.pn'));
      final splitted = filePath.substring(0, (lastIndex));
      final outPath = "${splitted}_bsky_compressed.jpg";

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, 
        outPath,
        quality: 70, // Turunkan kualitas ke 70% (biasanya cukup bagus tapi size turun drastis)
        minWidth: 1920, // Resize resolusi jika terlalu besar (misal 4K jadi FHD)
        minHeight: 1920,
        format: CompressFormat.jpeg, // Paksa jadi JPG karena PNG itu besar
      );

      if (result != null) {
        return File(result.path);
      }
      return null;
    } catch (e) {
      print("Error Compression: $e");
      return null;
    }
  }

  void dispose() {
    _twitter.dispose();
  }
}