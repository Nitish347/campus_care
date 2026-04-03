class TransportRoute {
  final String id;
  final String routeNumber;
  final String routeName;
  final String startLocation;
  final String endLocation;
  final String? morningStartTime;
  final String? morningEndTime;
  final String? afternoonStartTime;
  final String? afternoonEndTime;
  final double? distanceKm;
  final int? estimatedDurationMinutes;
  final bool isActive;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportRoute({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.startLocation,
    required this.endLocation,
    this.morningStartTime,
    this.morningEndTime,
    this.afternoonStartTime,
    this.afternoonEndTime,
    this.distanceKm,
    this.estimatedDurationMinutes,
    required this.isActive,
    required this.instituteId,
    required this.createdAt,
    required this.updatedAt,
  });

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      final unix = value > 10000000000 ? value ~/ 1000 : value;
      return DateTime.fromMillisecondsSinceEpoch(unix * 1000);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  static int? _parseIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is num) return value.toInt();
    return null;
  }

  static double? _parseDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  factory TransportRoute.fromJson(Map<String, dynamic> json) {
    return TransportRoute(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      routeNumber:
          (json['route_number'] ?? json['routeNumber'] ?? '').toString(),
      routeName: (json['route_name'] ?? json['routeName'] ?? '').toString(),
      startLocation:
          (json['start_location'] ?? json['startLocation'] ?? '').toString(),
      endLocation:
          (json['end_location'] ?? json['endLocation'] ?? '').toString(),
      morningStartTime: json['morning_start_time']?.toString() ??
          json['morningStartTime']?.toString(),
      morningEndTime: json['morning_end_time']?.toString() ??
          json['morningEndTime']?.toString(),
      afternoonStartTime: json['afternoon_start_time']?.toString() ??
          json['afternoonStartTime']?.toString(),
      afternoonEndTime: json['afternoon_end_time']?.toString() ??
          json['afternoonEndTime']?.toString(),
      distanceKm: _parseDoubleOrNull(json['distance_km'] ?? json['distanceKm']),
      estimatedDurationMinutes: _parseIntOrNull(
          json['estimated_duration_minutes'] ??
              json['estimatedDurationMinutes']),
      isActive: _parseBool(json['is_active'] ?? json['isActive']),
      instituteId:
          (json['institute_id'] ?? json['instituteId'] ?? '').toString(),
      createdAt:
          _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt:
          _parseDate(json['updated_at'] ?? json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route_number': routeNumber,
      'route_name': routeName,
      'start_location': startLocation,
      'end_location': endLocation,
      'morning_start_time': morningStartTime,
      'morning_end_time': morningEndTime,
      'afternoon_start_time': afternoonStartTime,
      'afternoon_end_time': afternoonEndTime,
      'distance_km': distanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_active': isActive ? 1 : 0,
      'institute_id': instituteId,
    };
  }

  TransportRoute copyWith({
    String? id,
    String? routeNumber,
    String? routeName,
    String? startLocation,
    String? endLocation,
    String? morningStartTime,
    String? morningEndTime,
    String? afternoonStartTime,
    String? afternoonEndTime,
    double? distanceKm,
    int? estimatedDurationMinutes,
    bool? isActive,
    String? instituteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportRoute(
      id: id ?? this.id,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      morningStartTime: morningStartTime ?? this.morningStartTime,
      morningEndTime: morningEndTime ?? this.morningEndTime,
      afternoonStartTime: afternoonStartTime ?? this.afternoonStartTime,
      afternoonEndTime: afternoonEndTime ?? this.afternoonEndTime,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes:
          estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      isActive: isActive ?? this.isActive,
      instituteId: instituteId ?? this.instituteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
