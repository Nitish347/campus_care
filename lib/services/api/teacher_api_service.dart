import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for teacher operations
class TeacherApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all teachers with optional filters
  Future<List<dynamic>> getTeachers({
    String? instituteId,
    String? subject,
  }) async {
    final queryParams = <String, dynamic>{};
    if (instituteId != null) queryParams['instituteId'] = instituteId;
    if (subject != null) queryParams['subject'] = subject;

    final response = await _apiClient.get(
      AppConstants.teachersEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get teacher by ID
  Future<Map<String, dynamic>?> getTeacherById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.teachersEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new teacher
  Future<Map<String, dynamic>> createTeacher(
    Map<String, dynamic> teacherData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.teachersEndpoint,
      body: teacherData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create teacher');
  }

  /// Update teacher
  Future<Map<String, dynamic>> updateTeacher(
    String id,
    Map<String, dynamic> teacherData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.teachersEndpoint}/$id',
      body: teacherData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update teacher');
  }

  /// Delete teacher
  Future<void> deleteTeacher(String id) async {
    await _apiClient.delete('${AppConstants.teachersEndpoint}/$id');
  }
}
