import 'package:campus_care/core/api_client.dart';
import 'package:campus_care/core/constants/app_constants.dart';
import 'package:campus_care/models/teacher_attendance_model.dart';
import 'package:campus_care/services/institute_context_service.dart';
import 'package:campus_care/services/storage_service.dart';
import 'package:get/get.dart';

class TeacherAttendanceApiService {
  final ApiClient _apiClient = ApiClient();

  String get _endpoint => AppConstants.teacherAttendanceEndpoint;

  String? get _selectedInstituteId {
    if (StorageService.userRole != AppConstants.roleSuperAdmin) return null;
    if (!Get.isRegistered<InstituteContextService>()) return null;
    final id = Get.find<InstituteContextService>().currentInstituteId;
    return id == null || id.trim().isEmpty ? null : id.trim();
  }

  String _withAdminId(String path) {
    final adminId = _selectedInstituteId;
    if (adminId == null) return path;
    final separator = path.contains('?') ? '&' : '?';
    return '$path${separator}admin_id=${Uri.encodeQueryComponent(adminId)}';
  }

  Map<String, dynamic>? _queryWithAdminId(Map<String, dynamic> params) {
    final adminId = _selectedInstituteId;
    if (adminId != null) params['admin_id'] = adminId;
    return params.isEmpty ? null : params;
  }

  Future<List<TeacherGeofence>> getGeofences({bool? isActive}) async {
    final params = <String, dynamic>{};
    if (isActive != null) params['is_active'] = isActive ? 1 : 0;

    final response = await _apiClient.get(
      '$_endpoint/geofences',
      queryParameters: _queryWithAdminId(params),
    );

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map>()
        .map(
            (item) => TeacherGeofence.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TeacherGeofence> createGeofence(TeacherGeofence geofence) async {
    final response = await _apiClient.post(
      _withAdminId('$_endpoint/geofences'),
      body: geofence.toJson(),
    );
    return TeacherGeofence.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<TeacherGeofence> updateGeofence(TeacherGeofence geofence) async {
    final response = await _apiClient.patch(
      _withAdminId('$_endpoint/geofences/${geofence.id}'),
      body: geofence.toJson(),
    );
    return TeacherGeofence.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<void> deleteGeofence(String id) async {
    await _apiClient.delete(_withAdminId('$_endpoint/geofences/$id'));
  }

  Future<List<TeacherAttendanceLog>> getRecords({
    String? teacherId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    final params = <String, dynamic>{};
    if (teacherId != null && teacherId.isNotEmpty) {
      params['teacher_id'] = teacherId;
    }
    if (startDate != null) {
      params['startDate'] = startDate.millisecondsSinceEpoch ~/ 1000;
    }
    if (endDate != null) {
      params['endDate'] = endDate.millisecondsSinceEpoch ~/ 1000;
    }
    if (status != null && status.isNotEmpty) params['status'] = status;

    final response = await _apiClient.get(
      '$_endpoint/records',
      queryParameters: _queryWithAdminId(params),
    );

    final data = response['data'] as List<dynamic>? ?? [];
    return data
        .whereType<Map>()
        .map((item) =>
            TeacherAttendanceLog.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<TeacherAttendanceLog> createManualRecord({
    required String teacherId,
    required DateTime date,
    required DateTime checkInAt,
    DateTime? checkOutAt,
    String? remarks,
  }) async {
    final localDate = DateTime(date.year, date.month, date.day);
    final response = await _apiClient.post(
      _withAdminId('$_endpoint/records/manual'),
      body: {
        'teacher_id': teacherId,
        'date': localDate.millisecondsSinceEpoch ~/ 1000,
        'check_in_at': checkInAt.millisecondsSinceEpoch ~/ 1000,
        if (checkOutAt != null)
          'check_out_at': checkOutAt.millisecondsSinceEpoch ~/ 1000,
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
    );
    return TeacherAttendanceLog.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<TeacherAttendanceLog> addManualCheckOut({
    required String recordId,
    required DateTime checkOutAt,
    String? remarks,
  }) async {
    final response = await _apiClient.post(
      _withAdminId('$_endpoint/records/$recordId/manual-check-out'),
      body: {
        'check_out_at': checkOutAt.millisecondsSinceEpoch ~/ 1000,
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
    );
    return TeacherAttendanceLog.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }

  Future<TeacherAttendanceLog?> getToday({required DateTime date}) async {
    final localDate = DateTime(date.year, date.month, date.day);
    final response = await _apiClient.get(
      '$_endpoint/me/today',
      queryParameters: {
        'date': localDate.millisecondsSinceEpoch ~/ 1000,
      },
    );
    final data = response['data'];
    if (data is! Map) return null;
    return TeacherAttendanceLog.fromJson(Map<String, dynamic>.from(data));
  }

  Future<TeacherAttendanceLog> checkIn({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    String? remarks,
  }) async {
    return _submitLocation(
      path: '$_endpoint/check-in',
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      remarks: remarks,
    );
  }

  Future<TeacherAttendanceLog> checkOut({
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    String? remarks,
  }) async {
    return _submitLocation(
      path: '$_endpoint/check-out',
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: accuracyMeters,
      remarks: remarks,
    );
  }

  Future<TeacherAttendanceLog> _submitLocation({
    required String path,
    required double latitude,
    required double longitude,
    required double accuracyMeters,
    String? remarks,
  }) async {
    final now = DateTime.now();
    final localDate = DateTime(now.year, now.month, now.day);
    final response = await _apiClient.post(
      path,
      body: {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy_meters': accuracyMeters,
        'date': localDate.millisecondsSinceEpoch ~/ 1000,
        if (remarks != null && remarks.trim().isNotEmpty)
          'remarks': remarks.trim(),
      },
    );
    return TeacherAttendanceLog.fromJson(
      Map<String, dynamic>.from(response['data'] as Map),
    );
  }
}
