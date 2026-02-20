import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/models/timetable_model.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/services/student_service.dart';

import '../services/storage_service.dart';

class TimetableController extends GetxController {
  final _isLoading = false.obs;
  final _timetables = <TimeTableModel>[].obs;
  final _selectedClass = Rxn<String>();
  final _selectedSection = Rxn<String>();
  final _currentTimetable = Rxn<TimeTableModel>();
  final _availableClasses = <String>[].obs;
  final _availableSections = <String>[].obs;

  final TimetableApiService _apiService = TimetableApiService();

  bool get isLoading => _isLoading.value;
  List<TimeTableModel> get timetables => _timetables;
  String? get selectedClass => _selectedClass.value;
  String? get selectedSection => _selectedSection.value;
  TimeTableModel? get currentTimetable => _currentTimetable.value;
  List<String> get availableClasses => _availableClasses;
  List<String> get availableSections => _availableSections;

  @override
  void onInit() {
    super.onInit();
    loadTimetables();
    _loadAvailableClasses();
  }

  Future<void> _loadAvailableClasses() async {
    try {
      final students = await StudentService.getAllStudents();
      final classes = students.map((s) => s.class_ ?? "").toSet().toList();
      classes.sort();
      _availableClasses.value = classes;
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadAvailableSections() async {
    if (_selectedClass.value == null) {
      _availableSections.value = [];
      return;
    }
    try {
      final students = await StudentService.getAllStudents();
      final sections = students
          .where((s) => s.class_ == _selectedClass.value)
          .map((s) => s.section ?? "")
          .toSet()
          .toList();
      sections.sort();
      _availableSections.value = sections;
    } catch (e) {
      _availableSections.value = [];
    }
  }

  Future<void> loadTimetables({String? classId, String? section}) async {
    try {
      _isLoading.value = true;
      final data = await _apiService.getTimetables(
        classId: classId,
        section: section,
      );

      // Group timetable entries by class and section
      final Map<String, Map<String, List<TimeTableItem>>> groupedByClass = {};

      for (var entry in data) {
        final classKey =
            '${entry['class_id'] ?? entry['class'] ?? ''}_${entry['section'] ?? ''}';
        final day = entry['day_of_week'] ?? entry['dayOfWeek'] ?? '';

        if (!groupedByClass.containsKey(classKey)) {
          groupedByClass[classKey] = {};
        }

        if (!groupedByClass[classKey]!.containsKey(day)) {
          groupedByClass[classKey]![day] = [];
        }

        // Extract teacherId - handle both string and object (populated) formats
        String teacherId = '';
        final teacherIdField = entry['teacher_id'] ?? entry['teacherId'];
        if (teacherIdField is String) {
          teacherId = teacherIdField;
        } else if (teacherIdField is Map) {
          teacherId = teacherIdField['_id'] ?? teacherIdField['id'] ?? '';
        }

        groupedByClass[classKey]![day]!.add(TimeTableItem(
          period: 'P${groupedByClass[classKey]![day]!.length + 1}',
          subject: entry['subject_id'] ?? entry['subject'] ?? '',
          teacherId: teacherId,
          room: entry['room_number'] ?? entry['room'],
          startTime: entry['start_time'] ?? entry['startTime'] ?? '',
          endTime: entry['end_time'] ?? entry['endTime'] ?? '',
          type: 'class',
        ));
      }

      // Convert grouped data to TimeTableModel list
      _timetables.value = groupedByClass.entries.map((entry) {
        final parts = entry.key.split('_');
        return TimeTableModel(
          id: entry.key,
          classId: parts[0],
          section: parts[1],
          weeklySchedule: entry.value,
        );
      }).toList();

      _updateCurrentTimetable();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load timetables: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void selectClass(String? classId) {
    _selectedClass.value = classId;
    _selectedSection.value = null;
    if (classId != null) {
      _loadAvailableSections();
      loadTimetables(classId: classId);
    } else {
      _availableSections.value = [];
      _currentTimetable.value = null;
    }
  }

  void selectSection(String? section) {
    _selectedSection.value = section;
    if (_selectedClass.value != null && section != null) {
      loadTimetables(classId: _selectedClass.value, section: section);
    } else {
      _updateCurrentTimetable();
    }
  }

  void resetSelection() {
    _selectedClass.value = null;
    _selectedSection.value = null;
    _currentTimetable.value = null;
    loadTimetables();
  }

  void _updateCurrentTimetable() {
    if (_selectedClass.value != null && _selectedSection.value != null) {
      _currentTimetable.value = _timetables.firstWhereOrNull(
        (tt) =>
            tt.classId == _selectedClass.value &&
            tt.section == _selectedSection.value,
      );
    } else {
      _currentTimetable.value = null;
    }
  }

  Future<void> saveTimetable(TimeTableModel timetable) async {
    try {
      _isLoading.value = true;

      // Get the current admin's institute ID from stored user data
      final currentUser = await StorageService.currentUser;
      final instituteId = currentUser?['id'] ?? '';

      if (instituteId.isEmpty) {
        throw Exception('Institute ID not found. Please log in again.');
      }

      print(
          'DEBUG: Saving timetable with class_id: ${timetable.classId}, institute_id: $instituteId');

      // First, delete all existing timetable entries for this class/section
      // This ensures we replace the old schedule instead of adding duplicates
      await _apiService.deleteTimetableByClassSection(
        timetable.classId,
        timetable.section,
      );

      // Transform the weekly schedule into individual timetable entries
      final List<Map<String, dynamic>> timetableEntries = [];

      timetable.weeklySchedule.forEach((day, periods) {
        int periodNumber = 1;
        for (var period in periods) {
          // Extract period number from period string (e.g., "P1" -> 1)
          final periodNum =
              int.tryParse(period.period.replaceAll(RegExp(r'[^0-9]'), '')) ??
                  periodNumber;

          print(
              'DEBUG: Period data - teacher_id: ${period.teacherId}, subject_id: ${period.subject}, class_id: ${timetable.classId}');

          timetableEntries.add({
            'period_number': periodNum,
            'teacher_id': period.teacherId.isNotEmpty ? period.teacherId : null,
            'subject_id': period.subject.isNotEmpty ? period.subject : null,
            'day_of_week': day,
            'start_time': period.startTime,
            'end_time': period.endTime,
            'room_number': (period.room != null && period.room!.isNotEmpty)
                ? period.room
                : null,
            'class_id': timetable.classId,
            'section': timetable.section,
            'institute_id': instituteId,
            'is_active': 1,
          });
          periodNumber++;
        }
      });

      // Batch create all timetable entries
      await _apiService.createTimetable(timetableEntries);

      Get.snackbar(
        'Success',
        'Timetable saved successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Reload timetables to show updated data
      await loadTimetables();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save timetable: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteTimetable(String id) async {
    try {
      _isLoading.value = true;
      await _apiService.deleteTimetable(id);

      // Reload from API
      await loadTimetables();

      Get.snackbar('Success', 'Timetable deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete timetable: $e');
    } finally {
      _isLoading.value = false;
    }
  }
}
