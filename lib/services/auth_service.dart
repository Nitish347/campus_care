import 'package:campus_care/models/user.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/services/api/auth_api_service.dart';
import 'package:campus_care/core/api_exception.dart';

class AuthService {
  static final AuthApiService _authApiService = AuthApiService();

  /// Login with email, password, and role
  static Future<Map<String, dynamic>?> login(String email, String password, String role) async {
    try {
      final result = await _authApiService.login(
        email: email,
        password: password,
        role: role,
      );

      final userData = result['user'];
      if (userData != null) {
        // final user = User.fromJson(userData);

        // Store login state
        await StorageService.setLoggedIn(true);
        await StorageService.setCurrentUser(userData);
        await StorageService.setUserRole(userData['role']);

        return userData;
      }

      return null;
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Logout - clear all stored data
  static Future<void> logout() async {
    await _authApiService.logout();
  }

  /// Get current logged-in user
  static User? getCurrentUser() {
    final userData = StorageService.currentUser;
    if (userData != null) {
      return User.fromJson(userData);
    }
    return null;
  }


  /// Check if user is logged in
  static bool get isLoggedIn => StorageService.isLoggedIn;

  /// Get current user role
  static String? get userRole => StorageService.userRole;

  /// Check if user is authenticated (has valid token)
  static bool get isAuthenticated => _authApiService.isAuthenticated();

  /// Register a new student
  static Future<Map<String, dynamic>> registerStudent(
    Map<String, dynamic> studentData,
  ) async {
    try {
      return await _authApiService.registerStudent(
        studentData: studentData,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Register a new teacher
  static Future<Map<String, dynamic>> registerTeacher(
    Map<String, dynamic> teacherData,
  ) async {
    try {
      return await _authApiService.registerTeacher(
        teacherData: teacherData,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Register a new admin
  static Future<Map<String, dynamic>> registerAdmin(
    Map<String, dynamic> adminData,
  ) async {
    try {
      return await _authApiService.registerAdmin(
        adminData: adminData,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Verify OTP
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
  ) async {
    try {
      return await _authApiService.verifyOTP(
        email: email,
        otp: otp,
      );
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Resend OTP
  static Future<void> resendOTP(String email) async {
    try {
      await _authApiService.resendOTP(email: email);
    } on ApiException catch (e) {
      throw Exception(e.message);
    } catch (e) {
      throw Exception('Failed to resend OTP: $e');
    }
  }

  /// Change password (kept for compatibility, may need backend endpoint)
  static Future<bool> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    // TODO: Implement change password API endpoint on backend
    // For now, return false as this functionality needs backend support
    return false;
  }

  /// Update profile (kept for compatibility, may need backend endpoint)
  static Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    // TODO: Implement update profile API endpoint on backend
    // For now, return false as this functionality needs backend support
    return false;
  }
}
