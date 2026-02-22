import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';

/// API service for attendance operations
class AttendanceApiService {
  final ApiClient _apiClient = ApiClient();

  /// Get attendance records with optional filters
  Future<List<dynamic>> getAttendance({
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
      // Parse YYYY-MM-DD and build local midnight boundaries, then convert to UTC.
      // This ensures the query window matches the timezone where the app is running,
      // because attendance 'date' is stored as local midnight unix seconds.
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
      AppConstants.attendanceEndpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }

  /// Get attendance by ID
  Future<Map<String, dynamic>?> getAttendanceById(String id) async {
    final response = await _apiClient.get(
      '${AppConstants.attendanceEndpoint}/$id',
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    return null;
  }

  /// Mark attendance
  Future<Map<String, dynamic>> markAttendance(
    Map<String, dynamic> attendanceData,
  ) async {
    final response = await _apiClient.post(
      AppConstants.attendanceEndpoint,
      body: attendanceData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to mark attendance');
  }

  /// Update attendance
  Future<Map<String, dynamic>> updateAttendance(
    String id,
    Map<String, dynamic> attendanceData,
  ) async {
    final response = await _apiClient.patch(
      '${AppConstants.attendanceEndpoint}/$id',
      body: attendanceData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update attendance');
  }

  /// Bulk mark attendance
  Future<List<dynamic>> bulkMarkAttendance(
    List<Map<String, dynamic>> attendanceData,
  ) async {
    final response = await _apiClient.post(
      '${AppConstants.attendanceEndpoint}/bulk',
      body: {'attendanceData': attendanceData},
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as List<dynamic>;
    }

    throw Exception('Failed to mark bulk attendance');
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String id) async {
    await _apiClient.delete('${AppConstants.attendanceEndpoint}/$id');
  }
}
