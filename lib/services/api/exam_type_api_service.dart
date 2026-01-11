import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for exam type operations
class ExamTypeApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all exam types with optional filters
  Future<List<dynamic>> getExamTypes({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null) queryParams['isActive'] = isActive.toString();

    final response = await _apiClient.get(
      AppConstants.examTypesEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get exam type by ID
  Future<Map<String, dynamic>?> getExamTypeById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.examTypesEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new exam type
  Future<Map<String, dynamic>> createExamType(
    Map<String, dynamic> examTypeData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.examTypesEndpoint,
      body: examTypeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create exam type');
  }

  /// Update exam type
  Future<Map<String, dynamic>> updateExamType(
    String id,
    Map<String, dynamic> examTypeData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.examTypesEndpoint}/$id',
      body: examTypeData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update exam type');
  }

  /// Delete exam type
  Future<void> deleteExamType(String id) async {
    await _apiClient.delete('${AppConstants.examTypesEndpoint}/$id');
  }
}
