import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs => _prefs!;

  // Authentication storage
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await prefs.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  static bool get isLoggedIn =>
      prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;

  static Future<void> setCurrentUser(Map<String, dynamic> user) async {
    await prefs.setString(AppConstants.keyCurrentUser, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> get currentUser async  {
    final userData = prefs.getString(AppConstants.keyCurrentUser);
    if (userData != null) {
      try {
        return jsonDecode(userData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> setUserRole(String role) async {
    await prefs.setString(AppConstants.keyUserRole, role);
  }

  static String? get userRole => prefs.getString(AppConstants.keyUserRole);

  // Theme storage
  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(AppConstants.keyThemeMode, mode);
  }

  static String get themeMode =>
      prefs.getString(AppConstants.keyThemeMode) ?? 'system';

  // Generic string storage
  static Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return prefs.getString(key);
  }

  // Generic data storage
  static Future<void> saveData(
      String key, List<Map<String, dynamic>> data) async {
    try {
      await prefs.setString(key, jsonEncode(data));
    } catch (e) {
      throw Exception('Failed to save data: $e');
    }
  }

  static List<Map<String, dynamic>> getData(String key) {
    try {
      final data = prefs.getString(key);
      if (data != null) {
        final List<dynamic> jsonList = jsonDecode(data);
        return jsonList.map((item) => Map<String, dynamic>.from(item)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    await prefs.clear();
  }

  // Clear specific data
  static Future<void> clearData(String key) async {
    await prefs.remove(key);
  }

  // Check if data exists
  static bool hasData(String key) {
    return prefs.containsKey(key);
  }
}
