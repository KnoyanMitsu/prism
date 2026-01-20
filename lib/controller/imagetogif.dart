import 'dart:io';
import 'package:flutter/foundation.dart'; // Untuk compute
import 'package:image/image.dart' as img;

class GifMaker {
  /// Fungsi utama yang dipanggil dari UI
  static Future<File?> convertImageToGif(File sourceFile) async {
    try {
      // Jalankan proses berat di background thread (Isolate)
      final List<int>? resultBytes =
          await compute(_encodeToGif, sourceFile.path);

      if (resultBytes == null) return null;

      // Simpan hasilnya ke file baru .gif
      final String newPath =
          sourceFile.path.replaceAll(RegExp(r'\.\w+$'), '.gif');
      final File gifFile = File(newPath);
      await gifFile.writeAsBytes(resultBytes);

      return gifFile;
    } catch (e) {
      print("Error converting GIF: $e");
      return null;
    }
  }

  /// Fungsi internal yang berjalan di Isolate
  static List<int>? _encodeToGif(String path) {
    final bytes = File(path).readAsBytesSync();
    final img.Image? decoded = img.decodeImage(bytes); // Gambar Asli

    if (decoded == null) return null;

    // --- TEKNIK DUPLIKASI FRAME (Agar dianggap animasi) ---

    // Kita buat gambar dasar kosong (Canvas)
    final img.Image animation =
        img.Image(width: decoded.width, height: decoded.height);

    // Frame 1: Durasi 1 Detik
    // Kita clone (salin) gambar asli agar memori tidak bentrok
    final frame1 = decoded.clone();
    frame1.frameDuration = 1000; // 1000ms = 1 detik
    animation.addFrame(frame1);

    // Frame 2: Durasi 1 Detik (Gambar Sama)
    final frame2 = decoded.clone();
    frame2.frameDuration = 1000; // 1000ms = 1 detik
    animation.addFrame(frame2);

    // Total durasi = 2 Detik.
    // Encode canvas animation tadi
    final gifBytes = img.encodeGif(animation);

    return gifBytes;
  }
}
