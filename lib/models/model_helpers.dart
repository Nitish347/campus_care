// Helper functions for all models to handle camelCase <-> snake_case conversion
// Place this in a shared utils file

class ModelHelpers {
  /// Get value with fallback for both camelCase and snake_case
  static T? getValue<T>(
      Map<String, dynamic> json, String camelCase, String snakeCase) {
    return (json[snakeCase] ?? json[camelCase]) as T?;
  }

  /// Parse dates - handles both ISO strings and Unix timestamps (seconds or milliseconds)
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      // Handle both seconds and milliseconds timestamps
      if (value > 10000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  /// Parse boolean - handles both bool and int 0/1
  static bool parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  /// Convert DateTime to Unix timestamp in seconds (D1 expects seconds)
  static int? dateToTimestamp(DateTime? date) {
    return date != null ? date.millisecondsSinceEpoch ~/ 1000 : null;
  }
}
