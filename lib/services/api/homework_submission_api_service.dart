import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for homework submission operations
class HomeworkSubmissionApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all homework submissions with optional filters
  Future<List<dynamic>> getSubmissions({
    String? homeworkId,
    String? studentId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (homeworkId != null) queryParams['homeworkId'] = homeworkId;
    if (studentId != null) queryParams['studentId'] = studentId;

    final response = await _apiClient.get(
      AppConstants.homeworkSubmissionsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Alias for getSubmissions with homeworkId filter
  Future<List<dynamic>> getHomeworkSubmissions({String? homeworkId}) async {
    return getSubmissions(homeworkId: homeworkId);
  }

  /// Get submission by ID
  Future<Map<String, dynamic>?> getSubmissionById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.homeworkSubmissionsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new submission
  Future<Map<String, dynamic>> createSubmission(
    Map<String, dynamic> submissionData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.homeworkSubmissionsEndpoint,
      body: submissionData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create submission');
  }

  /// Update submission
  Future<Map<String, dynamic>> updateSubmission(
    String id,
    Map<String, dynamic> submissionData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.homeworkSubmissionsEndpoint}/$id',
      body: submissionData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update submission');
  }

  /// Alias for updateSubmission
  Future<Map<String, dynamic>> updateHomeworkSubmission(
    String id,
    Map<String, dynamic> submissionData,
  ) async {
    return updateSubmission(id, submissionData);
  }

  /// Delete submission
  Future<void> deleteSubmission(String id) async {
    await _apiClient.delete('${AppConstants.homeworkSubmissionsEndpoint}/$id');
  }
}
