import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for exam result operations
class ExamResultApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get exam results with optional filters
  Future<List<dynamic>> getExamResults({
    String? examId,
    String? studentId,
    String? classId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (examId != null) queryParams['examId'] = examId;
    if (studentId != null) queryParams['studentId'] = studentId;
    if (classId != null) queryParams['classId'] = classId;

    final response = await _apiClient.get(
      AppConstants.examResultsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get exam result by ID
  Future<Map<String, dynamic>?> getExamResultById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.examResultsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create exam result
  Future<Map<String, dynamic>> createExamResult(
    Map<String, dynamic> resultData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.examResultsEndpoint,
      body: resultData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create exam result');
  }

  /// Update exam result
  Future<Map<String, dynamic>> updateExamResult(
    String id,
    Map<String, dynamic> resultData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.examResultsEndpoint}/$id',
      body: resultData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update exam result');
  }

  /// Delete exam result
  Future<void> deleteExamResult(String id) async {
    await _apiClient.delete('${AppConstants.examResultsEndpoint}/$id');
  }
}
