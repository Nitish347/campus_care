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
    if (date != null) queryParams['date'] = date;

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
    final response = await _apiClient.put(
      '${AppConstants.attendanceEndpoint}/$id',
      body: attendanceData,
    );

    if (response['success'] == true && response['data'] != null) {
      return response['data'] as Map<String, dynamic>;
    }

    throw Exception('Failed to update attendance');
  }

  /// Delete attendance record
  Future<void> deleteAttendance(String id) async {
    await _apiClient.delete('${AppConstants.attendanceEndpoint}/$id');
  }
}
