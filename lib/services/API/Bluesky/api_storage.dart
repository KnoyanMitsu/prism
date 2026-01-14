import 'package:shared_preferences/shared_preferences.dart';

class BlueskyStorage {
  static const String _kServicesURL = 'services_url';
  static const String _kIdentifier = 'identifier';
  static const String _kPassword = 'password';


  Future<void> saveLoginData(String identifier, String password, String servicesURL) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kServicesURL, servicesURL);
    await prefs.setString(_kIdentifier, identifier);
    await prefs.setString(_kPassword, password);
  }

  Future<Map<String, String?>> getLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'identifier': prefs.getString(_kIdentifier),
      'password': prefs.getString(_kPassword),
      'servicesURL': prefs.getString(_kServicesURL),
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kServicesURL);
    await prefs.remove(_kIdentifier);
    await prefs.remove(_kPassword);
  }
}