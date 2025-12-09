import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for homework operations
class HomeworkApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all homework with optional filters
  Future<List<dynamic>> getHomework({
    String? classId,
    String? section,
    String? subject,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;
    if (section != null) queryParams['section'] = section;
    if (subject != null) queryParams['subject'] = subject;

    final response = await _apiClient.get(
      AppConstants.homeworkEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get homework by ID
  Future<Map<String, dynamic>?> getHomeworkById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.homeworkEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new homework
  Future<Map<String, dynamic>> createHomework(
    Map<String, dynamic> homeworkData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.homeworkEndpoint,
      body: homeworkData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create homework');
  }

  /// Update homework
  Future<Map<String, dynamic>> updateHomework(
    String id,
    Map<String, dynamic> homeworkData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.homeworkEndpoint}/$id',
      body: homeworkData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update homework');
  }

  /// Delete homework
  Future<void> deleteHomework(String id) async {
    await _apiClient.delete('${AppConstants.homeworkEndpoint}/$id');
  }
}
