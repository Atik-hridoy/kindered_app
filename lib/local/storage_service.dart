
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'storage_keys.dart';

class LocalStorage {
  static String get myProfileImage =>
      preferences?.getString(LocalStorageKeys.myProfileImage) ?? '';
  static String token = "";
  static String cookie = "";
  static String refreshToken = "";
  static bool isLogIn = false;
  static String userId = "";
  static String myImage = "";
  static String myName = "";
  static String myEmail = "";
  static String myAddress = ""; // Address storage
  static String get myPhone => preferences?.getString(LocalStorageKeys.phone) ?? "";
  static String phone = ""; // Phone number storage

  static SharedPreferences? preferences;

  /// Get SharedPreferences instance
  static Future<SharedPreferences> _getStorage() async {
    preferences ??= await SharedPreferences.getInstance();
    return preferences!;
  }

  // Get All Data From SharedPreferences
static Future<void> getAllPrefData() async {
  final localStorage = await _getStorage();

  token = localStorage.getString(LocalStorageKeys.token) ?? "";
  cookie = localStorage.getString(LocalStorageKeys.cookie) ?? "";
  refreshToken = localStorage.getString(LocalStorageKeys.refreshToken) ?? "";
  isLogIn = localStorage.getBool(LocalStorageKeys.isLogIn) ?? false;
  userId = localStorage.getString(LocalStorageKeys.userId) ?? "";
  myImage = localStorage.getString(LocalStorageKeys.myImage) ?? "";
  myName = localStorage.getString(LocalStorageKeys.myName) ?? "";
  myEmail = localStorage.getString(LocalStorageKeys.myEmail) ?? "";
  phone = localStorage.getString(LocalStorageKeys.phone) ?? "";

  
}

  /// Save String
  static Future<void> setString(String key, String value) async {
    final localStorage = await _getStorage();
    await localStorage.setString(key, value);
  }

  /// Save Bool
  static Future<void> setBool(String key, bool value) async {
    final localStorage = await _getStorage();
    await localStorage.setBool(key, value);
  }

  /// Get String by key
  static Future<String> getString(String key) async {
    final localStorage = await _getStorage();
    return localStorage.getString(key) ?? '';
  }

  /// Optional: Clear everything (on logout)
  static Future<void> clearAll() async {
    final localStorage = await _getStorage();
    await localStorage.clear();

    token = "";
    cookie = "";
    refreshToken = "";
    isLogIn = false;
    userId = "";
    myImage = "";
    myName = "";
    myEmail = "";
    myAddress = "";
    phone = "";

    AppLogger.info("🔐 Local storage cleared");
  }
}