import 'package:campus_care/models/timetable_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:campus_care/services/api/timetable_api_service.dart';
import 'package:campus_care/controllers/auth_controller.dart';

import '../utils/timetable_parser.dart';

class TeacherTimetableController extends GetxController {
  final TimetableApiService _apiService = TimetableApiService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<TimeTableModel> timetable = <TimeTableModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString selectedDay = ''.obs;

  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchTeacherTimetable();
  }

  /// Fetch timetable for the authenticated teacher
  Future<void> fetchTeacherTimetable() async {
    try {
      isLoading.value = true;

      final teacher = _authController.currentTeacher;
      if (teacher == null) {
        Get.snackbar('Error', 'Teacher not authenticated');
        return;
      }

      final data = await _apiService.getTimetables(teacherId: teacher.id);
      timetable.value =
          TimetableParser.parseFromDatabase(data.cast<Map<String, dynamic>>());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load timetable: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Get today's classes
  List<TimeTableItem> getTodaysClasses() {
    final today = _getCurrentDay();
    return getClassesForDay(today);
  }

  /// Get classes for a specific day
  List<TimeTableItem> getClassesForDay(String day) {
    List<TimeTableItem> items = [];
    for (var table in timetable) {
      if (table.weeklySchedule.containsKey(day)) {
        items.addAll(table.weeklySchedule[day]!);
      }
    }
    // Sort by start time
    items.sort((a, b) => a.startTime.compareTo(b.startTime));
    return items;
  }

  /// Get current day of week
  String _getCurrentDay() {
    final now = DateTime.now();
    final dayIndex = now.weekday - 1; // Monday = 0
    if (dayIndex >= 0 && dayIndex < daysOfWeek.length) {
      return daysOfWeek[dayIndex];
    }
    return 'Monday';
  }

  /// Get next class
  TimeTableItem? getNextClass() {
    final todaysClasses = getTodaysClasses();
    if (todaysClasses.isEmpty) return null;

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    for (var classItem in todaysClasses) {
      final startTime = _parseTime(classItem.startTime);
      if (startTime != null && _isAfter(startTime, currentTime)) {
        return classItem;
      }
    }

    return null;
  }

  /// Get current ongoing class
  TimeTableItem? getCurrentClass() {
    final todaysClasses = getTodaysClasses();
    if (todaysClasses.isEmpty) return null;

    final now = DateTime.now();
    final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);

    for (var classItem in todaysClasses) {
      final startTime = _parseTime(classItem.startTime);
      final endTime = _parseTime(classItem.endTime);

      if (startTime != null && endTime != null) {
        if (_isAfter(currentTime, startTime) &&
            _isBefore(currentTime, endTime)) {
          return classItem;
        }
      }
    }

    return null;
  }

  /// Set day filter
  void setDayFilter(String day) {
    selectedDay.value = day;
  }

  /// Clear day filter
  void clearDayFilter() {
    selectedDay.value = '';
  }

  /// Get filtered timetable items
  List<TimeTableItem> get filteredTimetable {
    if (selectedDay.value.isEmpty) {
      // Return all items from all days
      List<TimeTableItem> allItems = [];
      for (var table in timetable) {
        table.weeklySchedule.forEach((day, items) {
          allItems.addAll(items);
        });
      }
      return allItems;
    }
    return getClassesForDay(selectedDay.value);
  }

  /// Parse time string to TimeOfDay
  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Handle parse error
    }
    return null;
  }

  /// Compare two TimeOfDay objects
  int _compareTime(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) {
      return a.hour.compareTo(b.hour);
    }
    return a.minute.compareTo(b.minute);
  }

  /// Check if time a is after time b
  bool _isAfter(TimeOfDay a, TimeOfDay b) {
    return _compareTime(a, b) > 0;
  }

  /// Check if time a is before time b
  bool _isBefore(TimeOfDay a, TimeOfDay b) {
    return _compareTime(a, b) < 0;
  }

  /// Get timetable statistics
  Map<String, dynamic> getStats() {
    // Get unique classes
    final uniqueClasses =
        timetable.map((t) => '${t.classId}-${t.section}').toSet().length;

    // Get unique subjects
    Set<String> uniqueSubjects = {};
    for (var table in timetable) {
      table.weeklySchedule.forEach((day, items) {
        for (var item in items) {
          uniqueSubjects.add(item.subject);
        }
      });
    }

    // Count total periods
    int totalPeriods = 0;
    for (var table in timetable) {
      table.weeklySchedule.forEach((day, items) {
        totalPeriods += items.length;
      });
    }

    return {
      'totalClasses': uniqueClasses,
      'totalSubjects': uniqueSubjects.length,
      'totalPeriods': totalPeriods,
      'todayPeriods': getTodaysClasses().length,
    };
  }

  /// Get timetable for a specific class
  TimeTableModel? getTimetableForClass(String classId, String section) {
    try {
      return timetable.firstWhere(
        (t) => t.classId == classId && t.section == section,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get all unique classes teacher teaches
  List<Map<String, String>> getUniqueClasses() {
    return timetable
        .map((t) => {
              'classId': t.classId,
              'section': t.section,
              'display': '${t.classId} - ${t.section}',
            })
        .toList();
  }
}
