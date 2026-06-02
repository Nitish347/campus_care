import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for student operations
class StudentApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all students
  Future<List<dynamic>> getStudents({
    Map<String, dynamic>? filters,
  }) async {
    final queryParameters = <String, dynamic>{
      ...?filters,
      'page': filters?['page'] ?? 1,
      'limit': filters?['limit'] ?? AppConstants.defaultPageSize,
    };

    final response = await _apiClient.get(
      AppConstants.studentsEndpoint,
      queryParameters: queryParameters,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  Future<Map<String, dynamic>> getDashboardSummary() async {
    final response = await _apiClient.get(
      '${AppConstants.studentsEndpoint}/me/dashboard-summary',
    );

    if (response['success'] == true && response['data'] != null) {
      return Map<String, dynamic>.from(response['data'] as Map);
    }

    throw Exception(response['message'] ?? 'Failed to load dashboard summary');
  }

  Future<Map<String, dynamic>> getStudentsPage({
    required int page,
    required int limit,
    String? search,
    String? classId,
    String? section,
    String? sortBy,
    String? sortOrder,
  }) async {
    final queryParameters = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (classId != null && classId.isNotEmpty) 'class': classId,
      if (section != null && section.isNotEmpty) 'section': section,
      if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      if (sortOrder != null && sortOrder.isNotEmpty) 'sortOrder': sortOrder,
    };

    final response = await _apiClient.get(
      AppConstants.studentsEndpoint,
      queryParameters: queryParameters,
    );

    if (response['success'] == true) {
      return Map<String, dynamic>.from(response as Map);
    }

    throw Exception(response['message'] ?? 'Failed to load students');
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
    final response = await getStudentsPage(
      page: 1,
      limit: AppConstants.defaultPageSize,
      search: query,
    );

    return response['data'] as List<dynamic>? ?? [];
  }
}
