import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for subject operations
class SubjectApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all subjects with optional filters
  Future<List<dynamic>> getSubjects({
    String? classId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;

    final response = await _apiClient.get(
      AppConstants.subjectsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get subject by ID
  Future<Map<String, dynamic>?> getSubjectById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.subjectsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new subject
  Future<Map<String, dynamic>> createSubject(
    Map<String, dynamic> subjectData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.subjectsEndpoint,
      body: subjectData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create subject');
  }

  /// Update subject
  Future<Map<String, dynamic>> updateSubject(
    String id,
    Map<String, dynamic> subjectData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.subjectsEndpoint}/$id',
      body: subjectData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update subject');
  }

  /// Delete subject
  Future<void> deleteSubject(String id) async {
    await _apiClient.delete('${AppConstants.subjectsEndpoint}/$id');
  }
}
