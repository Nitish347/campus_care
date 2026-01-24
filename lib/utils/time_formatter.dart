import 'package:flutter/material.dart';

class TimeFormatter {
  /// Convert 24-hour time string to 12-hour format with AM/PM
  /// Example: "14:30" -> "02:30 PM"
  static String to12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';

      // Convert hour to 12-hour format
      if (hour == 0) {
        hour = 12;
      } else if (hour > 12) {
        hour = hour - 12;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  /// Convert TimeOfDay to 12-hour format string with AM/PM
  /// Example: TimeOfDay(hour: 14, minute: 30) -> "02:30 PM"
  static String timeOfDayTo12Hour(TimeOfDay time) {
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');

    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// Convert 12-hour time string with AM/PM to 24-hour format
  /// Example: "02:30 PM" -> "14:30"
  static String to24Hour(String time12) {
    try {
      // Remove extra spaces and split
      time12 = time12.trim();
      final parts = time12.split(' ');
      if (parts.length != 2) return time12;

      final timeParts = parts[0].split(':');
      if (timeParts.length != 2) return time12;

      int hour = int.parse(timeParts[0]);
      final minute = timeParts[1];
      final period = parts[1].toUpperCase();

      // Convert to 24-hour format
      if (period == 'PM' && hour != 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return '${hour.toString().padLeft(2, '0')}:$minute';
    } catch (e) {
      return time12;
    }
  }

  /// Format TimeOfDay to 24-hour string
  /// Example: TimeOfDay(hour: 14, minute: 30) -> "14:30"
  static String timeOfDayTo24Hour(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Parse 24-hour time string to TimeOfDay
  static TimeOfDay? parse24Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      // Return null if parsing fails
    }
    return null;
  }
}
