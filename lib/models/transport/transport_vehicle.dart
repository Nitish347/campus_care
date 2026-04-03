class TransportVehicle {
  final String id;
  final String vehicleNumber;
  final String vehicleType;
  final int capacity;
  final String? model;
  final String? manufacturer;
  final DateTime? registrationExpiry;
  final DateTime? insuranceExpiry;
  final DateTime? fitnessExpiry;
  final String? gpsDeviceId;
  final bool isActive;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportVehicle({
    required this.id,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.capacity,
    this.model,
    this.manufacturer,
    this.registrationExpiry,
    this.insuranceExpiry,
    this.fitnessExpiry,
    this.gpsDeviceId,
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

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is num) return value.toInt();
    return defaultValue;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  factory TransportVehicle.fromJson(Map<String, dynamic> json) {
    return TransportVehicle(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      vehicleNumber:
          (json['vehicle_number'] ?? json['vehicleNumber'] ?? '').toString(),
      vehicleType:
          (json['vehicle_type'] ?? json['vehicleType'] ?? 'van').toString(),
      capacity: _parseInt(json['capacity']),
      model: json['model']?.toString(),
      manufacturer: json['manufacturer']?.toString(),
      registrationExpiry:
          _parseDate(json['registration_expiry'] ?? json['registrationExpiry']),
      insuranceExpiry:
          _parseDate(json['insurance_expiry'] ?? json['insuranceExpiry']),
      fitnessExpiry:
          _parseDate(json['fitness_expiry'] ?? json['fitnessExpiry']),
      gpsDeviceId:
          json['gps_device_id']?.toString() ?? json['gpsDeviceId']?.toString(),
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
      'vehicle_number': vehicleNumber,
      'vehicle_type': vehicleType,
      'capacity': capacity,
      'model': model,
      'manufacturer': manufacturer,
      'registration_expiry': registrationExpiry != null
          ? registrationExpiry!.millisecondsSinceEpoch ~/ 1000
          : null,
      'insurance_expiry': insuranceExpiry != null
          ? insuranceExpiry!.millisecondsSinceEpoch ~/ 1000
          : null,
      'fitness_expiry': fitnessExpiry != null
          ? fitnessExpiry!.millisecondsSinceEpoch ~/ 1000
          : null,
      'gps_device_id': gpsDeviceId,
      'is_active': isActive ? 1 : 0,
      'institute_id': instituteId,
    };
  }

  TransportVehicle copyWith({
    String? id,
    String? vehicleNumber,
    String? vehicleType,
    int? capacity,
    String? model,
    String? manufacturer,
    DateTime? registrationExpiry,
    DateTime? insuranceExpiry,
    DateTime? fitnessExpiry,
    String? gpsDeviceId,
    bool? isActive,
    String? instituteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportVehicle(
      id: id ?? this.id,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      capacity: capacity ?? this.capacity,
      model: model ?? this.model,
      manufacturer: manufacturer ?? this.manufacturer,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      fitnessExpiry: fitnessExpiry ?? this.fitnessExpiry,
      gpsDeviceId: gpsDeviceId ?? this.gpsDeviceId,
      isActive: isActive ?? this.isActive,
      instituteId: instituteId ?? this.instituteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
