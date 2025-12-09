import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for timetable operations
class TimetableApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get all timetables with optional filters
  Future<List<dynamic>> getTimetables({
    String? classId,
    String? section,
    String? teacherId,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;
    if (section != null) queryParams['section'] = section;
    if (teacherId != null) queryParams['teacherId'] = teacherId;

    final response = await _apiClient.get(
      AppConstants.timetablesEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get timetable by ID
  Future<Map<String, dynamic>?> getTimetableById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.timetablesEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Create new timetable
  Future<Map<String, dynamic>> createTimetable(
    Map<String, dynamic> timetableData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.timetablesEndpoint,
      body: timetableData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to create timetable');
  }

  /// Update timetable
  Future<Map<String, dynamic>> updateTimetable(
    String id,
    Map<String, dynamic> timetableData,
  ) async {
    final response = await _apiClient.put(
      '${AppConstants.timetablesEndpoint}/$id',
      body: timetableData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update timetable');
  }

  /// Delete timetable
  Future<void> deleteTimetable(String id) async {
    await _apiClient.delete('${AppConstants.timetablesEndpoint}/$id');
  }
}
