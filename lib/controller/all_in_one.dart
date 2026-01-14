import 'dart:io';
import 'package:prism/controller/bluesky_controller.dart';
import 'package:prism/controller/twitter_controller.dart';

class ThePrismController {
  final TwitterController _twitter = TwitterController();
  final BlueskyController _bsky = BlueskyController();

  // Status Login (Cache)
  bool _isTwitterReady = false;
  bool _isBskyReady = false;

  // 1. INIT (Panggil ini di initState halaman PostsPage)
  Future<void> init() async {
    _isTwitterReady = await _twitter.init();
    _isBskyReady = await _bsky.init();
    print("Prism Status -> Twitter: $_isTwitterReady, Bluesky: $_isBskyReady");
  }

  // 2. FUNGSI UTAMA (Dipanggil tombol POST)
  Future<String> broadcast(String text, List<File> images) async {
    // Pastikan status login terupdate (jaga-jaga)
    await init(); 

    if (!_isTwitterReady && !_isBskyReady) {
      return "Anda belum login ke akun manapun!";
    }

    List<String> reports = [];

    // --- LOGIKA TWITTER ---
    if (_isTwitterReady) {
      String result;
      if (images.isNotEmpty) {
        // Post Gambar ke Twitter
        result = await _twitter.postTweetWithImages(text, images);
      } else {
        // Post Teks ke Twitter
        result = await _twitter.postTweet(text);
      }
      reports.add("X: $result");
    }

    // --- LOGIKA BLUESKY ---
    if (_isBskyReady) {
      String result;
      if (images.isNotEmpty) {
        // Post Gambar ke Bluesky
        // Pastikan nama method sama dengan di BlueskyController (postImage)
        result = await _bsky.postImage(text, images); 
      } else {
        // Post Teks ke Bluesky
        result = await _bsky.postFeed(text);
      }
      reports.add("BSKY: $result");
    }

    // Gabungkan laporan (biar user tau status semua sosmed)
    return reports.join("\n");
  }
  
  // Dispose jangan lupa
  void dispose() {
    _twitter.dispose();
    // _bsky tidak perlu dispose kalau tidak pakai ChangeNotifier
  }
}