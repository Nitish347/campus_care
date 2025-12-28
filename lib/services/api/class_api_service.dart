import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for class operations
class ClassApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all classes with optional filters
  Future<List<dynamic>> getClasses({
    String? instituteId,
    String? grade,
  }) async {
    final queryParams = <String, dynamic>{};
    if (instituteId != null) queryParams['instituteId'] = instituteId;
    if (grade != null) queryParams['grade'] = grade;

    final response = await _apiClient.get(
      AppConstants.classesEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get class by ID
  Future<Map<String, dynamic>?> getClassById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.classesEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new class
  Future<Map<String, dynamic>> createClass(
    Map<String, dynamic> classData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.classesEndpoint,
      body: classData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create class');
  }

  /// Update class
  Future<Map<String, dynamic>> updateClass(
    String id,
    Map<String, dynamic> classData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.classesEndpoint}/$id',
      body: classData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update class');
  }

  /// Delete class
  Future<void> deleteClass(String id) async {
    await _apiClient.delete('${AppConstants.classesEndpoint}/$id');
  }

  /// Add section to class
  Future<Map<String, dynamic>> addSection(String id, String section) async {
    final response = await _apiClient.patch(
      '${AppConstants.classesEndpoint}/$id/sections',
      body: {'section': section},
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to add section');
  }
}
