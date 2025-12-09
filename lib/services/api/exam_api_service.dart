import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for exam operations
class ExamApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all exams with optional filters
  Future<List<dynamic>> getExams({
    String? classId,
    String? section,
    String? subject,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;
    if (section != null) queryParams['section'] = section;
    if (subject != null) queryParams['subject'] = subject;

    final response = await _apiClient.get(
      AppConstants.examsEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get exam by ID
  Future<Map<String, dynamic>?> getExamById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.examsEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new exam
  Future<Map<String, dynamic>> createExam(
    Map<String, dynamic> examData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.examsEndpoint,
      body: examData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create exam');
  }

  /// Update exam
  Future<Map<String, dynamic>> updateExam(
    String id,
    Map<String, dynamic> examData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.examsEndpoint}/$id',
      body: examData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update exam');
  }

  /// Delete exam
  Future<void> deleteExam(String id) async {
    await _apiClient.delete('${AppConstants.examsEndpoint}/$id');
  }
}
