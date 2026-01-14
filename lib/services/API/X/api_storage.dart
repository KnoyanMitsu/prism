import 'package:shared_preferences/shared_preferences.dart';
import 'package:twitter_api_v2/twitter_api_v2.dart' as v2;

class TwitterStorage {
  // Key untuk SharedPreferences
  static const String _kApiKey = 'consumer_key';
  static const String _kApiSecret = 'consumer_secret';
  static const String _kAccessToken = 'access_token';
  static const String _kTokenSecret = 'token_secret';
  // 1. Definisikan Key Baru untuk Profile
  static const String _kName = 'user_name';
  static const String _kUsername = 'user_username';
  static const String _kBio = 'user_bio';
  static const String _kImage = 'user_image';
  static const String _kFollowers = 'user_followers';
  static const String _kBearerToken = 'bearer_token';
  static const String _kUsageused = 'usage_used';
  static const String _kUsageLimit = 'usage_limit';
  // Simpan API Key & Secret (Inputan User)
  Future<void> saveApiKeys(String key, String secret) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kApiKey, key);
    await prefs.setString(_kApiSecret, secret);
  }

  // Simpan Token Login (Hasil Login User)
  Future<void> saveUserTokens(
    String token,
    String secret,
    String BearerToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessToken, token);
    await prefs.setString(_kTokenSecret, secret);
    await prefs.setString(_kBearerToken, BearerToken);
  }

  // Ambil Semua Data (Credential)
  Future<Map<String, String?>> getCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'apiKey': prefs.getString(_kApiKey),
      'apiSecret': prefs.getString(_kApiSecret),
      'accessToken': prefs.getString(_kAccessToken),
      'tokenSecret': prefs.getString(_kTokenSecret),
      'BearerToken': prefs.getString(_kBearerToken),
    };
  }

  Future<void> saveUserData(v2.UserData userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan Nama & Username
    await prefs.setString(_kName, userData.name);
    await prefs.setString(_kUsername, userData.username);

    // Simpan Bio (Harus cek null, karena user bisa aja gak punya bio)
    // Di API V2 namanya 'description', bukan 'bio'
    await prefs.setString(_kBio, userData.description ?? "");

    // Simpan Foto (Cek null juga)
    await prefs.setString(_kImage, userData.profileImageUrl ?? "");

    // Simpan Followers (Letaknya ada di publicMetrics)
    // Kita simpan sebagai Int saja biar rapi
    if (userData.publicMetrics != null) {
      await prefs.setInt(
        _kFollowers,
        userData.publicMetrics!.followersCount ?? 0,
      );
    }

    // Tidak perlu return apa-apa karena void
  }
  // Future<UserData?> getUserData() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userData = prefs.getString(_kUserData);
  //   return userData != null ? UserData.fromJson(jsonDecode(userData)) : null;
  // }
  // Hapus Data (Logout)

  Future<Map<String, dynamic>> getCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_kName),
      'username': prefs.getString(_kUsername),
      'bio': prefs.getString(_kBio),
      'image': prefs.getString(_kImage),
      'followers': prefs.getInt(_kFollowers),
    };
  }

  Future<Map<String, dynamic>> getUsageMonthly() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'used': prefs.getString(_kUsageused),
      'limit': prefs.getString(_kUsageLimit),
    };
  }

  Future<void> saveUsageMonthly(String used, String limit) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUsageused, used);
    await prefs.setString(_kUsageLimit, limit);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessToken);
    await prefs.remove(_kTokenSecret);
    await prefs.remove(_kName);
    await prefs.remove(_kUsername);
    await prefs.remove(_kBio);
    await prefs.remove(_kImage);
    await prefs.remove(_kFollowers);
    await prefs.remove(_kBearerToken);
    // API Key tidak dihapus agar user tidak perlu input ulang kalau cuma relogin
  }
}
