import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:campus_care/models/user.dart';

/// API service for authentication operations
class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  /// Login with role-specific endpoint
  /// Returns user data and token on success
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    // Determine the login endpoint based on role
    String loginEndpoint;
    switch (role) {
      case AppConstants.roleStudent:
        loginEndpoint = '${AppConstants.authEndpoint}/login/student';
        break;
      case AppConstants.roleTeacher:
        loginEndpoint = '${AppConstants.authEndpoint}/login/teacher';
        break;
      case AppConstants.roleAdmin:
      case AppConstants.roleSuperAdmin:
        loginEndpoint = '${AppConstants.authEndpoint}/login/admin';
        break;
      default:
        loginEndpoint = '${AppConstants.authEndpoint}/login/student';
    }

    final response = await _apiClient.post(
      loginEndpoint,
      body: {
        'email': email,
        'password': password,
      },
      includeAuth: false,
    );

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

    throw Exception('Invalid login response');
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
