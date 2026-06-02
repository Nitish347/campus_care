import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class StorageService {
  static SharedPreferences? _prefs;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static final Map<String, String> _secureCache = {};
  static const Set<String> _secureKeys = {
    AppConstants.keyAuthToken,
    AppConstants.keyRefreshToken,
    AppConstants.keyCurrentUser,
    AppConstants.keyUserRole,
  };
  static const Set<String> _metadataMirrorKeys = {
    AppConstants.keyCurrentUser,
    AppConstants.keyUserRole,
  };

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSecureCache();
    await _migrateAuthDataToSecureStorage();
  }

  static bool get isInitialized => _prefs != null;

  static SharedPreferences get prefs {
    final instance = _prefs;
    if (instance == null) {
      throw StateError('StorageService.init() must be called before writes.');
    }
    return instance;
  }

  // Authentication storage
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    await prefs.setBool(AppConstants.keyIsLoggedIn, isLoggedIn);
  }

  static bool get isLoggedIn {
    final legacyFlag = _prefs?.getBool(AppConstants.keyIsLoggedIn) ?? false;
    final hasSession =
        (getString(AppConstants.keyAuthToken)?.isNotEmpty ?? false) &&
            (userRole?.isNotEmpty ?? false);
    return legacyFlag || hasSession;
  }

  static Future<void> setCurrentUser(Map<String, dynamic> user) async {
    await _setSecureString(AppConstants.keyCurrentUser, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> get currentUser async {
    final userData = _secureCache[AppConstants.keyCurrentUser] ??
        await _secureStorage.read(key: AppConstants.keyCurrentUser) ??
        _prefs?.getString(AppConstants.keyCurrentUser);
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
    await _setSecureString(AppConstants.keyUserRole, role);
  }

  static String? get userRole =>
      _secureCache[AppConstants.keyUserRole] ??
      _prefs?.getString(AppConstants.keyUserRole);

  // Theme storage
  static Future<void> setThemeMode(String mode) async {
    await prefs.setString(AppConstants.keyThemeMode, mode);
  }

  static String get themeMode =>
      _prefs?.getString(AppConstants.keyThemeMode) ?? 'system';

  // Generic string storage
  static Future<void> setString(String key, String value) async {
    if (_isSecureKey(key)) {
      await _setSecureString(key, value);
      return;
    }
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    if (_isSecureKey(key)) {
      return _secureCache[key] ?? _webFallbackString(key);
    }
    return _prefs?.getString(key);
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
      final data = _prefs?.getString(key);
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
    for (final key in _secureKeys) {
      await _clearSecureString(key);
    }
  }

  // Clear specific data
  static Future<void> clearData(String key) async {
    if (_isSecureKey(key)) {
      await _clearSecureString(key);
      return;
    }
    await prefs.remove(key);
  }

  // Check if data exists
  static bool hasData(String key) {
    if (_isSecureKey(key)) {
      return _secureCache.containsKey(key) || _webFallbackString(key) != null;
    }
    return _prefs?.containsKey(key) ?? false;
  }

  static bool _isSecureKey(String key) => _secureKeys.contains(key);

  static Future<void> _loadSecureCache() async {
    _secureCache.clear();
    for (final key in _secureKeys) {
      String? value;
      try {
        value = await _secureStorage.read(key: key);
      } catch (_) {
        value = null;
      }
      value ??= _webFallbackString(key);
      if (value != null && value.isNotEmpty) {
        _secureCache[key] = value;
      }
    }
  }

  static Future<void> _setSecureString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (_) {
      // Web secure storage can be unavailable in some debug/browser contexts.
    }
    _secureCache[key] = value;
    if (_shouldMirrorKey(key)) {
      await prefs.setString(key, value);
    }
  }

  static Future<void> _clearSecureString(String key) async {
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {
      // Keep logout resilient even if secure storage is unavailable.
    }
    _secureCache.remove(key);
    if (_shouldMirrorKey(key)) {
      await prefs.remove(key);
    }
  }

  static Future<void> _migrateAuthDataToSecureStorage() async {
    for (final key in _secureKeys) {
      if (_secureCache.containsKey(key)) {
        if (!_shouldMirrorKey(key)) {
          await prefs.remove(key);
        }
        continue;
      }

      final legacyValue = _prefs?.getString(key);
      if (legacyValue != null && legacyValue.isNotEmpty) {
        await _setSecureString(key, legacyValue);
        if (!_shouldMirrorKey(key)) {
          await prefs.remove(key);
        }
      }
    }
  }

  static bool _shouldMirrorKey(String key) {
    if (_metadataMirrorKeys.contains(key)) {
      return true;
    }
    return kIsWeb &&
        (key == AppConstants.keyAuthToken ||
            key == AppConstants.keyRefreshToken);
  }

  static String? _webFallbackString(String key) {
    if (!kIsWeb || !_shouldMirrorKey(key)) {
      return null;
    }
    return _prefs?.getString(key);
  }
}
