import 'dart:developer';

import 'package:campus_care/models/timetable_model.dart';

/// Parser to convert flat timetable database records into TimeTableModel objects
class TimetableParser {
  /// Converts a list of database records into a list of TimeTableModel
  /// Groups records by class+section to create separate TimeTableModel instances
  static List<TimeTableModel> parseFromDatabase(
      List<Map<String, dynamic>> dbRecords) {
    if (dbRecords.isEmpty) return [];

    // Group records by classId and section
    final Map<String, List<Map<String, dynamic>>> groupedByClass = {};

    for (var record in dbRecords) {
      final classId = record['class'] ?? '';
      final section = record['section'] ?? '';
      final key = '$classId-$section';

      if (!groupedByClass.containsKey(key)) {
        groupedByClass[key] = [];
      }
      groupedByClass[key]!.add(record);
    }

    // Convert each group into a TimeTableModel
    final List<TimeTableModel> timetables = [];

    groupedByClass.forEach((key, records) {
      // Extract classId and section from the first record
      final firstRecord = records.first;
      final classId = firstRecord['class'] ?? '';
      final section = firstRecord['section'] ?? '';

      // Group records by day
      final Map<String, List<TimeTableItem>> weeklySchedule = {};

      for (var record in records) {
        final day = record['dayOfWeek'] ?? '';
        if (day.isEmpty) continue;

        if (!weeklySchedule.containsKey(day)) {
          weeklySchedule[day] = [];
        }

        // Create TimeTableItem from record
        final item = TimeTableItem(
          period: record['period'] ?? '',
          subject: record['subject'] ?? '',
          teacherId: record['teacherId']["_id"] ?? '',
          room: record['room'] ,
          startTime: record['startTime'] ?? '',
          endTime: record['endTime'] ?? '',
          type: record['type'] ?? 'class',
        );

        weeklySchedule[day]!.add(item);
      }

      // Sort items by start time for each day
      weeklySchedule.forEach((day, items) {
        items.sort((a, b) => a.startTime.compareTo(b.startTime));
      });

      log(weeklySchedule.toString());
      // Create TimeTableModel
      timetables.add(TimeTableModel(
        id: '',
        classId: classId,
        section: section,
        weeklySchedule: weeklySchedule,
      ));
    });

    return timetables;
  }

  /// Alternative: Parse into a single TimeTableModel for a specific class
  /// Use this when you already know the class and section
  static TimeTableModel? parseForClass(
    List<Map<String, dynamic>> dbRecords,
    String classId,
    String section,
  ) {
    if (dbRecords.isEmpty) return null;

    // Filter records for this specific class and section
    final classRecords = dbRecords
        .where((record) =>
            record['class'] == classId && record['section'] == section)
        .toList();

    if (classRecords.isEmpty) return null;

    // Group by day
    final Map<String, List<TimeTableItem>> weeklySchedule = {};

    for (var record in classRecords) {
      final day = record['dayOfWeek'] ?? '';
      if (day.isEmpty) continue;

      if (!weeklySchedule.containsKey(day)) {
        weeklySchedule[day] = [];
      }

      // Create TimeTableItem from record
      final item = TimeTableItem(
        period: record['period'] ?? '',
        subject: record['subject'] ?? '',
        teacherId: record['teacherId'] ?? '',
        room: record['room'],
        startTime: record['startTime'] ?? '',
        endTime: record['endTime'] ?? '',
        type: record['type'] ?? 'class',
      );

      weeklySchedule[day]!.add(item);
    }

    // Sort items by start time for each day
    weeklySchedule.forEach((day, items) {
      items.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return TimeTableModel(
      id: classRecords.first['_id'] ?? classRecords.first['id'] ?? '',
      classId: classId,
      section: section,
      weeklySchedule: weeklySchedule,
    );
  }
}
