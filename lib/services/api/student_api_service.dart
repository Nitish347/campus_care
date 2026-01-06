import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for student operations
class StudentApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all students
  Future<List<dynamic>> getStudents({
    Map<String, dynamic>? filters,
  }) async {
    final response = await _apiClient.get(
      AppConstants.studentsEndpoint,
      queryParameters: filters,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get student by ID
  Future<Map<String, dynamic>?> getStudentById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.studentsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create a new student
  Future<Map<String, dynamic>> createStudent(
    Map<String, dynamic> studentData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.studentsEndpoint,
      body: studentData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create student');
  }

  /// Update student
  Future<Map<String, dynamic>> updateStudent(
    String id,
    Map<String, dynamic> studentData,
  ) async {
    final response = await _apiClient.patch(
      '${AppConstants.studentsEndpoint}/$id',
      body: studentData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update student');
  }

  /// Delete student
  Future<void> deleteStudent(String id) async {
    await _apiClient.delete('${AppConstants.studentsEndpoint}/$id');
  }

  /// Search students
  Future<List<dynamic>> searchStudents(String query) async {
    final response = await _apiClient.get(
      AppConstants.studentsEndpoint,
      queryParameters: {'search': query},
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }
}
