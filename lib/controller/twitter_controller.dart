import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:prism/services/API/X/api_storage.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;
import 'package:oauth1/oauth1.dart' as oauth1;
import 'package:url_launcher/url_launcher.dart';
import 'package:app_links/app_links.dart';
import 'dart:io';

class TwitterController {
  final String _redirectUri = 'aceui://callback';

  v2.TwitterApi? _twitterApi;
  final TwitterStorage _storage = TwitterStorage();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _sub;

  Future<bool> init() async {
    final creds = await _storage.getCredentials();
    final apiKey = creds['apiKey'];
    final apiSecret = creds['apiSecret'];
    final token = creds['accessToken'];
    final tokenSecret = creds['tokenSecret'];

    if (apiKey != null &&
        apiSecret != null &&
        token != null &&
        tokenSecret != null) {
      _twitterApi = v2.TwitterApi(
        bearerToken: '',
        oauthTokens: v2.OAuthTokens(
          consumerKey: apiKey,
          consumerSecret: apiSecret,
          accessToken: token,
          accessTokenSecret: tokenSecret,
        ),
      );
      return true;
    }
    return false;
  }

  Future<String> login(
    String apiKey,
    String apiSecret,
    String BearerToken,
  ) async {
    final completer = Completer<String>();

    try {
      await _storage.saveApiKeys(apiKey, apiSecret);

      final platform = oauth1.Platform(
        'https://api.twitter.com/oauth/request_token',
        'https://api.twitter.com/oauth/authorize',
        'https://api.twitter.com/oauth/access_token',
        oauth1.SignatureMethods.hmacSha1,
      );

      final clientCredentials = oauth1.ClientCredentials(apiKey, apiSecret);
      final auth = oauth1.Authorization(clientCredentials, platform);

      final requestToken = await auth.requestTemporaryCredentials(_redirectUri);

      final url = Uri.parse(
        'https://api.twitter.com/oauth/authorize?oauth_token=${requestToken.credentials.token}',
      );

      try {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        return "Gagal membuka browser: $e";
      }

      _sub = _appLinks.uriLinkStream.listen(
        (Uri? uri) async {
          if (uri != null && uri.toString().startsWith('aceui')) {
            final verifier = uri.queryParameters['oauth_verifier'];

            if (verifier != null) {
              try {
                final accessToken = await auth.requestTokenCredentials(
                  requestToken.credentials,
                  verifier,
                );

                await _storage.saveUserTokens(
                  accessToken.credentials.token,
                  accessToken.credentials.tokenSecret,
                  BearerToken,
                );

                _twitterApi = v2.TwitterApi(
                  bearerToken: BearerToken,
                  oauthTokens: v2.OAuthTokens(
                    consumerKey: apiKey,
                    consumerSecret: apiSecret,
                    accessToken: accessToken.credentials.token,
                    accessTokenSecret: accessToken.credentials.tokenSecret,
                  ),
                );

                if (!completer.isCompleted) completer.complete("Success");
              } catch (e) {
                if (!completer.isCompleted)
                  completer.complete("Gagal tukar token: $e");
              } finally {
                _sub?.cancel();
              }
            }
          }
        },
        onError: (err) {
          if (!completer.isCompleted) completer.complete("Error Link: $err");
        },
      );
    } catch (e) {
      return "Exception: $e";
    }

    return completer.future;
  }

  Future<String> postTweet(String text) async {
    print(_twitterApi);
    if (_twitterApi == null) return "Belum Login";

    try {
      final response = await _twitterApi!.tweetsService.createTweet(text: text);
      return "Berhasil! ID: ${response.data.id}";
    } catch (e) {
      return "Gagal: $e";
    }
  }

  Future<v2.UserData?> checkUser() async {
    if (_twitterApi == null) return null;

    try {
      final response = await _twitterApi!.usersService.lookupMe(
        userFields: [
          v2.UserField.profileImageUrl,
          v2.UserField.description,
          v2.UserField.publicMetrics, // follower count, dll
          v2.UserField.verified,
        ],
      );
      _storage.saveUserData(response.data);
      return response.data;
    } catch (e) {
      print("error: $e");
      return null;
    }
  }

  Future<String> postTweetWithImages(String text, List<File> images) async {
    if (_twitterApi == null) return "Belum Login";

    try {
      List<String> mediaIds = [];

      // --- MULAI LOOPING ---
      // Kita loop array 'images' yang dari UI tadi
      for (var file in images) {
        print("Sedang mengupload: ${file.path}");

        // 1. Upload Media (Twitter pakai endpoint V1.1 untuk upload media)
        // Library twitter_api_v2 biasanya menyediakan akses ke v1 service
        final uploadedMedia = await _twitterApi!.mediaService.uploadImage(
          file: file,
        );
        // 2. Ambil ID-nya dan masukkan ke penampungan
        mediaIds.add(uploadedMedia.data.mediaId);
      }
      // --- SELESAI LOOPING ---

      // 3. Kirim Tweet dengan lampiran ID Media yang sudah dikumpulkan
      final response = await _twitterApi!.tweetsService.createTweet(
        text: text,
        media: v2.TweetMediaParam(mediaIds: mediaIds),
      );

      return "Berhasil Tweet dengan ${mediaIds.length} gambar!";
    } catch (e) {
      return "Gagal Upload: $e";
    }
  }

  Future<Map<String, dynamic>?> usageMonthly() async {
    if (_twitterApi == null) return null;

    try {
      final bearerToken = await _storage.getCredentials();
      final response = await http.get(
        Uri.parse('https://api.x.com/2/usage/tweets'),
        headers: {'Authorization': 'Bearer ${bearerToken['BearerToken']}'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Gagal mengambil data usage: ${response.body}");
      }
    } catch (e) {
      print("Error fetching usage: $e");
    }
    return null;
  }

  void dispose() {
    _sub?.cancel();
  }
}
