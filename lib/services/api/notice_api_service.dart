import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for notice operations
class NoticeApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all notices with optional filters
  Future<List<dynamic>> getNotices({
    String? classId,
    String? section,
    String? targetRole,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;
    if (section != null) queryParams['section'] = section;
    if (targetRole != null) queryParams['targetRole'] = targetRole;

    final response = await _apiClient.get(
      AppConstants.noticesEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get notice by ID
  Future<Map<String, dynamic>?> getNoticeById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.noticesEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new notice
  Future<Map<String, dynamic>> createNotice(
    Map<String, dynamic> noticeData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.noticesEndpoint,
      body: noticeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create notice');
  }

  /// Update notice
  Future<Map<String, dynamic>> updateNotice(
    String id,
    Map<String, dynamic> noticeData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.noticesEndpoint}/$id',
      body: noticeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update notice');
  }

  /// Delete notice
  Future<void> deleteNotice(String id) async {
    await _apiClient.delete('${AppConstants.noticesEndpoint}/$id');
  }
}
