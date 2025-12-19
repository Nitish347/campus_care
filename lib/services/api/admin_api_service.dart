import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

class AdminApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response =
        await _apiClient.get('${AppConstants.adminEndpoint}/dashboard/stats');
    return response['data'];
  }

  /// Get all admins
  Future<List<dynamic>> getAllAdmins() async {
    final response = await _apiClient.get('${AppConstants.adminEndpoint}/list');
    return response['data'];
  }

  /// Get admin by ID
  Future<Map<String, dynamic>> getAdminById(String id) async {
    final response = await _apiClient.get('${AppConstants.adminEndpoint}/$id');
    return response['data'];
  }

  /// Create new admin
  Future<Map<String, dynamic>> createAdmin(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '${AppConstants.adminEndpoint}/create',
      body: data,
    );
    return response['data'];
  }

  /// Update admin
  Future<Map<String, dynamic>> updateAdmin(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '${AppConstants.adminEndpoint}/$id',
      body: data,
    );
    return response['data'];
  }

  /// Delete admin
  Future<void> deleteAdmin(String id) async {
    await _apiClient.delete('${AppConstants.adminEndpoint}/$id');
  }

  /// Get all teachers (Admin view)
  Future<List<dynamic>> getAllTeachers() async {
    final response =
        await _apiClient.get('${AppConstants.adminEndpoint}/teachers');
    return response['data'];
  }

  /// Get all students (Admin view)
  Future<List<dynamic>> getAllStudents() async {
    final response =
        await _apiClient.get('${AppConstants.adminEndpoint}/students');
    return response['data'];
  }
}
