import 'dart:async';
import 'dart:io';

import 'package:bluesky/app_bsky_actor_defs.dart';
import 'package:bluesky/app_bsky_embed_images.dart';
import 'package:bluesky/app_bsky_feed_post.dart';
import 'package:bluesky/atproto.dart';
import 'package:bluesky/bluesky.dart';
import 'package:bluesky/core.dart';
import 'package:prism/services/API/Bluesky/api_storage.dart';

class BlueskyController {
  final BlueskyStorage _storage = BlueskyStorage();
  Bluesky? _bsky;
  StreamSubscription? _sub;

  Future<bool> init() async {
    final credentials = await _storage.getLoginData();
    if (credentials['identifier'] != null &&
        credentials['password'] != null &&
        credentials['servicesURL'] != null) {
      final session = await createSession(
        service: credentials['servicesURL']!,
        identifier: credentials['identifier']!,
        password: credentials['password']!,
      );

      _bsky = Bluesky.fromSession(
        session.data,
        retryConfig: RetryConfig(
          maxAttempts: 3,
          jitter: Jitter(minInSeconds: 1, maxInSeconds: 3),
        ),
      );
      return true;
    }
    return false;
  }

  Future<String> login(
    String identifier,
    String password,
    String servicesURL,
  ) async {
    try {
      final session = await createSession(
        service: servicesURL,
        identifier: identifier,
        password: password,
      );

      _bsky = Bluesky.fromSession(
        session.data,
        retryConfig: RetryConfig(
          maxAttempts: 3,
          jitter: Jitter(minInSeconds: 1, maxInSeconds: 3),
        ),
      );

      await _storage.saveLoginData(identifier, password, servicesURL);
      return "Success";
    } catch (e) {
      return "Gagal: $e";
    }
  }

  Future<ProfileViewDetailed> getProfile() async {
    if (_bsky == null) throw Exception("Belum Login");
    try {
      final response = await _bsky!.actor.getProfile(
        actor: _bsky!.session!.did,
      );
      print('Profile: ${_bsky!.session!.did}');
      return response.data;
    } catch (e) {
      throw Exception("Gagal: $e");
    }
  }

  Future<String> postFeed(String text) async {
    if (_bsky == null) return "Belum Login";
    try {
      final response = await _bsky!.feed.post.create(text: text);
      return "Berhasil! ID: ${response.data.cid}";
    } catch (e) {
      return "Gagal: $e";
    }
  }

  Future<String> postImage(String text, List<File> imageFiles) async {
    if (_bsky == null) return "Belum Login";

    try {
      // 1. Siapkan List untuk menampung ITEM gambar (EmbedImagesImage)
      // BUKAN menampung EmbedImages
      List<EmbedImagesImage> imageItems = [];

      // 2. Loop file dari parameter
      for (var file in imageFiles) {
        print("Sedang mengupload: ${file.path}");

        // A. Upload Blob
        final uploadedMedia = await _bsky!.atproto.repo.uploadBlob(
          bytes: file.readAsBytesSync(),
        );

        // B. Masukkan ke List sebagai 'EmbedImagesImage'
        imageItems.add(
          EmbedImagesImage(
            image: uploadedMedia.data.blob, // Blob hasil upload
            alt:
                "Image uploaded via Prism", // Alt text wajib (boleh string kosong)
          ),
        );
      }

      // 3. Create Post
      final response = await _bsky!.feed.post.create(
        text: text,
        // Struktur: UFeedPostEmbed -> EmbedImages -> List<EmbedImagesImage>
        embed: UFeedPostEmbed.embedImages(
          data: EmbedImages(
            images: imageItems, // Masukkan List tadi ke sini
          ),
        ),
      );

      return "Berhasil! ID: ${response.data.cid}";
    } catch (e) {
      return "Gagal: $e";
    }
    
  }
    void dispose() {
    _sub?.cancel();
  }
}
