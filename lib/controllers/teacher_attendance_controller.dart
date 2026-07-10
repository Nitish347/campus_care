import 'package:campus_care/core/api_exception.dart';
import 'package:campus_care/models/teacher_attendance_model.dart';
import 'package:campus_care/services/api/teacher_attendance_api_service.dart';
import 'package:campus_care/utils/app_notifier.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class TeacherAttendanceController extends GetxController {
  final TeacherAttendanceApiService _service = TeacherAttendanceApiService();

  final RxBool isLoading = false.obs;
  final RxBool isSubmittingLocation = false.obs;
  final RxList<TeacherGeofence> geofences = <TeacherGeofence>[].obs;
  final RxList<TeacherAttendanceLog> records = <TeacherAttendanceLog>[].obs;
  final Rxn<TeacherAttendanceLog> todayRecord = Rxn<TeacherAttendanceLog>();
  final Rxn<Position> lastPosition = Rxn<Position>();

  bool get hasCheckedIn => todayRecord.value?.checkInAt != null;
  bool get hasCheckedOut => todayRecord.value?.checkOutAt != null;

  Future<void> loadAdminData({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      isLoading.value = true;
      final from =
          startDate ?? DateTime.now().subtract(const Duration(days: 30));
      final to = endDate ?? DateTime.now().add(const Duration(days: 1));
      final selectedStatus = status == null || status == 'all' ? null : status;
      final results = await Future.wait([
        _service.getGeofences(),
        _service.getRecords(
          startDate: from,
          endDate: to,
          status: selectedStatus,
        ),
      ]);
      geofences.assignAll(results[0] as List<TeacherGeofence>);
      records.assignAll(results[1] as List<TeacherAttendanceLog>);
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadTeacherData() async {
    try {
      isLoading.value = true;
      final results = await Future.wait([
        _service.getGeofences(isActive: true),
        _service.getToday(date: DateTime.now()),
        _service.getRecords(
          startDate: DateTime.now().subtract(const Duration(days: 14)),
          endDate: DateTime.now().add(const Duration(days: 1)),
        ),
      ]);
      geofences.assignAll(results[0] as List<TeacherGeofence>);
      todayRecord.value = results[1] as TeacherAttendanceLog?;
      records.assignAll(results[2] as List<TeacherAttendanceLog>);
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> saveGeofence(TeacherGeofence geofence) async {
    try {
      isLoading.value = true;
      if (geofence.id.isEmpty) {
        await _service.createGeofence(geofence);
      } else {
        await _service.updateGeofence(geofence);
      }
      await loadAdminData();
      AppNotifier.success('Success', 'Geofence saved successfully.');
      return true;
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteGeofence(String id) async {
    try {
      isLoading.value = true;
      await _service.deleteGeofence(id);
      await loadAdminData();
      AppNotifier.success('Success', 'Geofence deleted successfully.');
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createManualRecord({
    required String teacherId,
    required DateTime date,
    required DateTime checkInAt,
    DateTime? checkOutAt,
    String? remarks,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterStatus,
  }) async {
    try {
      isLoading.value = true;
      await _service.createManualRecord(
        teacherId: teacherId,
        date: date,
        checkInAt: checkInAt,
        checkOutAt: checkOutAt,
        remarks: remarks,
      );
      await loadAdminData(
        startDate: filterStartDate,
        endDate: filterEndDate,
        status: filterStatus,
      );
      AppNotifier.success('Success', 'Manual attendance saved.');
      return true;
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addManualCheckOut({
    required String recordId,
    required DateTime checkOutAt,
    String? remarks,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    String? filterStatus,
  }) async {
    try {
      isLoading.value = true;
      await _service.addManualCheckOut(
        recordId: recordId,
        checkOutAt: checkOutAt,
        remarks: remarks,
      );
      await loadAdminData(
        startDate: filterStartDate,
        endDate: filterEndDate,
        status: filterStatus,
      );
      AppNotifier.success('Success', 'Teacher checkout added.');
      return true;
    } catch (e) {
      AppNotifier.error('Error', _friendlyError(e));
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIn({String? remarks}) async {
    await _submitLocation(
      actionLabel: 'check in',
      submit: (position) => _service.checkIn(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        remarks: remarks,
      ),
    );
  }

  Future<void> checkOut({String? remarks}) async {
    await _submitLocation(
      actionLabel: 'check out',
      submit: (position) => _service.checkOut(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        remarks: remarks,
      ),
    );
  }

  Future<Position> getCurrentPositionForGeofence() => _getCurrentPosition();

  Future<void> _submitLocation({
    required String actionLabel,
    required Future<TeacherAttendanceLog> Function(Position position) submit,
  }) async {
    try {
      isSubmittingLocation.value = true;
      final position = await _getCurrentPosition();
      lastPosition.value = position;
      todayRecord.value = await submit(position);
      await loadTeacherData();
      AppNotifier.success('Success', 'Teacher $actionLabel recorded.');
    } catch (e) {
      AppNotifier.error('Location Error', _friendlyError(e));
    } finally {
      isSubmittingLocation.value = false;
    }
  }

  Future<Position> _getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled on this device.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception(
          'Location permission is required for teacher attendance.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. Enable it from app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 18),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is ApiException) return error.message;
    return error.toString().replaceAll('Exception: ', '');
  }
}
