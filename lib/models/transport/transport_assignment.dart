class TransportAssignment {
  final String id;
  final String routeId;
  final String vehicleId;
  final String driverId;
  final String? attendantName;
  final String? attendantPhone;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String shift;
  final String status;
  final String instituteId;
  final String? routeNumber;
  final String? routeName;
  final String? vehicleNumber;
  final String? vehicleType;
  final String? driverFirstName;
  final String? driverLastName;
  final String? driverPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportAssignment({
    required this.id,
    required this.routeId,
    required this.vehicleId,
    required this.driverId,
    this.attendantName,
    this.attendantPhone,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.shift,
    required this.status,
    required this.instituteId,
    this.routeNumber,
    this.routeName,
    this.vehicleNumber,
    this.vehicleType,
    this.driverFirstName,
    this.driverLastName,
    this.driverPhone,
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

  factory TransportAssignment.fromJson(Map<String, dynamic> json) {
    return TransportAssignment(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      routeId: (json['route_id'] ?? json['routeId'] ?? '').toString(),
      vehicleId: (json['vehicle_id'] ?? json['vehicleId'] ?? '').toString(),
      driverId: (json['driver_id'] ?? json['driverId'] ?? '').toString(),
      attendantName: json['attendant_name']?.toString() ??
          json['attendantName']?.toString(),
      attendantPhone: json['attendant_phone']?.toString() ??
          json['attendantPhone']?.toString(),
      effectiveFrom:
          _parseDate(json['effective_from'] ?? json['effectiveFrom']) ??
              DateTime.now(),
      effectiveTo: _parseDate(json['effective_to'] ?? json['effectiveTo']),
      shift: (json['shift'] ?? 'both').toString(),
      status: (json['status'] ?? 'active').toString(),
      instituteId:
          (json['institute_id'] ?? json['instituteId'] ?? '').toString(),
      routeNumber:
          json['route_number']?.toString() ?? json['routeNumber']?.toString(),
      routeName:
          json['route_name']?.toString() ?? json['routeName']?.toString(),
      vehicleNumber: json['vehicle_number']?.toString() ??
          json['vehicleNumber']?.toString(),
      vehicleType:
          json['vehicle_type']?.toString() ?? json['vehicleType']?.toString(),
      driverFirstName: json['driver_first_name']?.toString() ??
          json['driverFirstName']?.toString(),
      driverLastName: json['driver_last_name']?.toString() ??
          json['driverLastName']?.toString(),
      driverPhone:
          json['driver_phone']?.toString() ?? json['driverPhone']?.toString(),
      createdAt:
          _parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt:
          _parseDate(json['updated_at'] ?? json['updatedAt']) ?? DateTime.now(),
    );
  }

  String get driverName {
    final first = driverFirstName?.trim() ?? '';
    final last = driverLastName?.trim() ?? '';
    return '$first $last'.trim();
  }

  Map<String, dynamic> toJson() {
    return {
      'route_id': routeId,
      'vehicle_id': vehicleId,
      'driver_id': driverId,
      'attendant_name': attendantName,
      'attendant_phone': attendantPhone,
      'effective_from': effectiveFrom.millisecondsSinceEpoch ~/ 1000,
      'effective_to': effectiveTo != null
          ? effectiveTo!.millisecondsSinceEpoch ~/ 1000
          : null,
      'shift': shift,
      'status': status,
      'institute_id': instituteId,
    };
  }

  TransportAssignment copyWith({
    String? id,
    String? routeId,
    String? vehicleId,
    String? driverId,
    String? attendantName,
    String? attendantPhone,
    DateTime? effectiveFrom,
    DateTime? effectiveTo,
    String? shift,
    String? status,
    String? instituteId,
    String? routeNumber,
    String? routeName,
    String? vehicleNumber,
    String? vehicleType,
    String? driverFirstName,
    String? driverLastName,
    String? driverPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportAssignment(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      attendantName: attendantName ?? this.attendantName,
      attendantPhone: attendantPhone ?? this.attendantPhone,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      instituteId: instituteId ?? this.instituteId,
      routeNumber: routeNumber ?? this.routeNumber,
      routeName: routeName ?? this.routeName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      driverFirstName: driverFirstName ?? this.driverFirstName,
      driverLastName: driverLastName ?? this.driverLastName,
      driverPhone: driverPhone ?? this.driverPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
