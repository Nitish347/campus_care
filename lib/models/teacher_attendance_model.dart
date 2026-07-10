class TeacherGeofence {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final bool isActive;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherGeofence({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.isActive,
    required this.instituteId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherGeofence.fromJson(Map<String, dynamic> json) {
    return TeacherGeofence(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      radiusMeters: _asDouble(json['radius_meters'] ?? json['radiusMeters']),
      isActive: _asBool(json['is_active'] ?? json['isActive']),
      instituteId: json['institute_id']?.toString() ?? '',
      createdAt: _asDate(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        if (id.isNotEmpty) 'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'radius_meters': radiusMeters,
        'is_active': isActive ? 1 : 0,
      };
}

class TeacherAttendanceLog {
  final String id;
  final String teacherId;
  final String? teacherFirstName;
  final String? teacherLastName;
  final String? teacherEmail;
  final DateTime date;
  final DateTime? checkInAt;
  final double? checkInLatitude;
  final double? checkInLongitude;
  final double? checkInAccuracyMeters;
  final double? checkInDistanceMeters;
  final DateTime? checkOutAt;
  final double? checkOutLatitude;
  final double? checkOutLongitude;
  final double? checkOutAccuracyMeters;
  final double? checkOutDistanceMeters;
  final String status;
  final String? remarks;
  final String instituteId;

  const TeacherAttendanceLog({
    required this.id,
    required this.teacherId,
    this.teacherFirstName,
    this.teacherLastName,
    this.teacherEmail,
    required this.date,
    this.checkInAt,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAccuracyMeters,
    this.checkInDistanceMeters,
    this.checkOutAt,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAccuracyMeters,
    this.checkOutDistanceMeters,
    required this.status,
    this.remarks,
    required this.instituteId,
  });

  String get teacherName {
    final name = '${teacherFirstName ?? ''} ${teacherLastName ?? ''}'.trim();
    return name.isEmpty ? teacherEmail ?? teacherId : name;
  }

  bool get isCheckedIn => checkInAt != null && checkOutAt == null;
  bool get isCheckedOut => checkOutAt != null;

  factory TeacherAttendanceLog.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceLog(
      id: json['id']?.toString() ?? '',
      teacherId: (json['teacher_id'] ?? json['teacherId'])?.toString() ?? '',
      teacherFirstName:
          (json['teacher_first_name'] ?? json['teacherFirstName'])?.toString(),
      teacherLastName:
          (json['teacher_last_name'] ?? json['teacherLastName'])?.toString(),
      teacherEmail: (json['teacher_email'] ?? json['teacherEmail'])?.toString(),
      date: _asDate(json['date']),
      checkInAt: _nullableDate(json['check_in_at'] ?? json['checkInAt']),
      checkInLatitude:
          _nullableDouble(json['check_in_latitude'] ?? json['checkInLatitude']),
      checkInLongitude: _nullableDouble(
          json['check_in_longitude'] ?? json['checkInLongitude']),
      checkInAccuracyMeters: _nullableDouble(
          json['check_in_accuracy_meters'] ?? json['checkInAccuracyMeters']),
      checkInDistanceMeters: _nullableDouble(
          json['check_in_distance_meters'] ?? json['checkInDistanceMeters']),
      checkOutAt: _nullableDate(json['check_out_at'] ?? json['checkOutAt']),
      checkOutLatitude: _nullableDouble(
          json['check_out_latitude'] ?? json['checkOutLatitude']),
      checkOutLongitude: _nullableDouble(
          json['check_out_longitude'] ?? json['checkOutLongitude']),
      checkOutAccuracyMeters: _nullableDouble(
          json['check_out_accuracy_meters'] ?? json['checkOutAccuracyMeters']),
      checkOutDistanceMeters: _nullableDouble(
          json['check_out_distance_meters'] ?? json['checkOutDistanceMeters']),
      status: json['status']?.toString() ?? 'checked_in',
      remarks: json['remarks']?.toString(),
      instituteId: json['institute_id']?.toString() ?? '',
    );
  }
}

double _asDouble(dynamic value) => _nullableDouble(value) ?? 0;

double? _nullableDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool _asBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    return normalized == 'true' || normalized == '1' || normalized == 'yes';
  }
  return false;
}

DateTime _asDate(dynamic value) => _nullableDate(value) ?? DateTime.now();

DateTime? _nullableDate(dynamic value) {
  if (value == null) return null;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(
      value > 10000000000 ? value : value * 1000,
    );
  }
  if (value is double) {
    final intValue = value.round();
    return DateTime.fromMillisecondsSinceEpoch(
      intValue > 10000000000 ? intValue : intValue * 1000,
    );
  }
  return DateTime.tryParse(value.toString());
}
