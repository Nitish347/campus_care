import 'package:campus_care/core/api_client.dart';

class AdminApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get admin dashboard statistics
  Future<Map<String, dynamic>> getDashboardStats() async {
    final response = await _apiClient.get('/admin/dashboard/stats');
    return response['data'];
  }

  /// Get all admins (superadmin only)
  Future<List<dynamic>> getAllAdmins() async {
    final response = await _apiClient.get('/admins');
    return response['data'];
  }

  /// Get admin by ID
  Future<Map<String, dynamic>> getAdminById(String id) async {
    final response = await _apiClient.get('/admins/$id');
    return response['data'];
  }

  /// Create new admin (superadmin only)
  Future<Map<String, dynamic>> createAdmin(Map<String, dynamic> data) async {
    final response = await _apiClient.post(
      '/admins',
      body: data,
    );
    return response['data'];
  }

  /// Update admin
  Future<Map<String, dynamic>> updateAdmin(
      String id, Map<String, dynamic> data) async {
    final response = await _apiClient.put(
      '/admins/$id',
      body: data,
    );
    return response['data'];
  }

  /// Delete admin (superadmin only)
  Future<void> deleteAdmin(String id) async {
    await _apiClient.delete('/admins/$id');
  }
}
