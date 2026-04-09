import 'dart:developer';

import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/services/storage_service.dart';

/// API service for authentication operations
class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  String _rolePath(String role) {
    switch (role) {
      case AppConstants.roleSuperAdmin:
        return 'super-admin';
      case AppConstants.roleAdmin:
        return 'admin';
      case AppConstants.roleTeacher:
        return 'teacher';
      case AppConstants.roleStudent:
        return 'student';
      default:
        return 'student';
    }
  }

  /// Login with role-specific endpoint
  /// Returns user data and token on success
  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
    required String role,
  }) async {
    // Determine the login endpoint based on role
    final loginEndpoint = '${AppConstants.authEndpoint}/login/${_rolePath(role)}';

    log('=== ABOUT TO CALL API ===');
    log('Login endpoint: $loginEndpoint');
    log('Identifier: $identifier');
    log('Role: $role');
    log('========================');

    final response = await _apiClient.post(
      loginEndpoint,
      body: {
        'identifier': identifier,
        'password': password,
      },
      includeAuth: false,
    );

    // Debug logging
    log('=== LOGIN RESPONSE ===');
    log('Full response: $response');
    log('Success: ${response['success']}');
    log('Data: ${response['data']}');
    log('====================');

    // Extract token and user data from response
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final token = data['token'];
      final user = data['user'];

      // Store token
      if (token != null) {
        await StorageService.setString(AppConstants.keyAuthToken, token);
      }

      return {
        'token': token,
        'user': user,
      };
    }

    log('Login failed - throwing exception');
    throw Exception('Invalid login response');
  }

  /// Send forgot-password OTP to email.
  Future<void> requestPasswordResetOtp({
    required String role,
    required String identifier,
  }) async {
    final endpoint =
        '${AppConstants.authEndpoint}/forgot-password/${_rolePath(role)}/request';
    await _apiClient.post(
      endpoint,
      body: {'identifier': identifier},
      includeAuth: false,
    );
  }

  /// Reset password using email + OTP.
  Future<void> resetPasswordWithOtp({
    required String role,
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final endpoint =
        '${AppConstants.authEndpoint}/forgot-password/${_rolePath(role)}/reset';
    await _apiClient.post(
      endpoint,
      body: {
        'email': email,
        'otp': otp,
        'new_password': newPassword,
      },
      includeAuth: false,
    );
  }

  /// Register a new student
  Future<Map<String, dynamic>> registerStudent({
    required Map<String, dynamic> studentData,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.authEndpoint}/register/student',
      body: studentData,
      includeAuth: false,
    );

    return response['data'];
  }

  /// Register a new teacher
  Future<Map<String, dynamic>> registerTeacher({
    required Map<String, dynamic> teacherData,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.authEndpoint}/register/teacher',
      body: teacherData,
      includeAuth: false,
    );

    return response['data'];
  }

  /// Register a new admin
  Future<Map<String, dynamic>> registerAdmin({
    required Map<String, dynamic> adminData,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.authEndpoint}/register/admin',
      body: adminData,
      includeAuth: false,
    );

    return response['data'];
  }

  /// Verify OTP
  Future<Map<String, dynamic>> verifyOTP({
    required String email,
    required String otp,
  }) async {
    final response = await _apiClient.post(
      '${AppConstants.authEndpoint}/verify-otp',
      body: {
        'email': email,
        'otp': otp,
      },
      includeAuth: false,
    );

    // Store token if verification successful
    if (response['success'] == true && response['data']?['token'] != null) {
      await StorageService.setString(
        AppConstants.keyAuthToken,
        response['data']['token'],
      );
    }

    return response['data'];
  }

  /// Resend OTP
  Future<void> resendOTP({required String email}) async {
    await _apiClient.post(
      '${AppConstants.authEndpoint}/resend-otp',
      body: {'email': email},
      includeAuth: false,
    );
  }

  /// Logout - clear local token
  Future<void> logout() async {
    await StorageService.clearData(AppConstants.keyAuthToken);
    await StorageService.clearData(AppConstants.keyCurrentUser);
    await StorageService.clearData(AppConstants.keyUserRole);
    await StorageService.setLoggedIn(false);
  }

  /// Check if user is authenticated
  bool isAuthenticated() {
    final token = StorageService.getString(AppConstants.keyAuthToken);
    return token != null && token.isNotEmpty;
  }

  /// Get stored auth token
  String? getAuthToken() {
    return StorageService.getString(AppConstants.keyAuthToken);
  }
}
