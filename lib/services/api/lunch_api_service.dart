import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for lunch operations
class LunchApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get lunch records with optional filters
  Future<List<dynamic>> getLunch({
    String? classId,
    String? section,
    String? studentId,
    String? date,
  }) async {
    final queryParams = <String, dynamic>{};
    if (classId != null) queryParams['classId'] = classId;
    if (section != null) queryParams['section'] = section;
    if (studentId != null) queryParams['studentId'] = studentId;
    if (date != null) {
      // Parse YYYY-MM-DD as local date and convert to UTC for timezone-aware query
      final parts = date.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final startLocal = DateTime(year, month, day, 0, 0, 0);
      final endLocal = DateTime(year, month, day, 23, 59, 59, 999);
      queryParams['startDate'] = startLocal.toUtc().toIso8601String();
      queryParams['endDate'] = endLocal.toUtc().toIso8601String();
    }

    final response = await _apiClient.get(
      AppConstants.lunchEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get lunch by ID
  Future<Map<String, dynamic>?> getLunchById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.lunchEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Mark lunch
  Future<Map<String, dynamic>> markLunch(
    Map<String, dynamic> lunchData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.lunchEndpoint,
      body: lunchData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to mark lunch');
  }

  /// Update lunch
  Future<Map<String, dynamic>> updateLunch(
    String id,
    Map<String, dynamic> lunchData,
  ) async {
    final response = await _apiClient.patch(
      '${AppConstants.lunchEndpoint}/$id',
      body: lunchData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update lunch');
  }

  /// Bulk mark lunch
  Future<List<dynamic>> bulkMarkLunch(
    List<Map<String, dynamic>> lunchData,
  ) async {
    final response = await _apiClient.post(
      '${AppConstants.lunchEndpoint}/bulk',
      body: {'lunchData': lunchData},
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    throw Exception('Failed to mark bulk lunch');
  }

  /// Delete lunch record
  Future<void> deleteLunch(String id) async {
    await _apiClient.delete('${AppConstants.lunchEndpoint}/$id');
  }

  /// Get lunch statistics
  Future<Map<String, dynamic>> getLunchStats({
    String? teacherId,
    String? studentId,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, dynamic>{};
    if (teacherId != null) queryParams['teacherId'] = teacherId;
    if (studentId != null) queryParams['studentId'] = studentId;
    if (startDate != null) queryParams['startDate'] = startDate;
    if (endDate != null) queryParams['endDate'] = endDate;

    final response = await _apiClient.get(
      '${AppConstants.lunchEndpoint}/stats',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return {};
  }
}
