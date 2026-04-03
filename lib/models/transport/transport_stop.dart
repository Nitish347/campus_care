class TransportStop {
  final String id;
  final String routeId;
  final String stopName;
  final String? stopAddress;
  final int sequenceNumber;
  final String? pickupTime;
  final String? dropTime;
  final double? latitude;
  final double? longitude;
  final bool isActive;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportStop({
    required this.id,
    required this.routeId,
    required this.stopName,
    this.stopAddress,
    required this.sequenceNumber,
    this.pickupTime,
    this.dropTime,
    this.latitude,
    this.longitude,
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

  static double? _parseDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    if (value is num) return value.toDouble();
    return null;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value == '1' || value.toLowerCase() == 'true';
    return false;
  }

  factory TransportStop.fromJson(Map<String, dynamic> json) {
    return TransportStop(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      routeId: (json['route_id'] ?? json['routeId'] ?? '').toString(),
      stopName: (json['stop_name'] ?? json['stopName'] ?? '').toString(),
      stopAddress:
          json['stop_address']?.toString() ?? json['stopAddress']?.toString(),
      sequenceNumber:
          _parseInt(json['sequence_number'] ?? json['sequenceNumber']),
      pickupTime:
          json['pickup_time']?.toString() ?? json['pickupTime']?.toString(),
      dropTime: json['drop_time']?.toString() ?? json['dropTime']?.toString(),
      latitude: _parseDoubleOrNull(json['latitude']),
      longitude: _parseDoubleOrNull(json['longitude']),
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
      'route_id': routeId,
      'stop_name': stopName,
      'stop_address': stopAddress,
      'sequence_number': sequenceNumber,
      'pickup_time': pickupTime,
      'drop_time': dropTime,
      'latitude': latitude,
      'longitude': longitude,
      'is_active': isActive ? 1 : 0,
      'institute_id': instituteId,
    };
  }

  TransportStop copyWith({
    String? id,
    String? routeId,
    String? stopName,
    String? stopAddress,
    int? sequenceNumber,
    String? pickupTime,
    String? dropTime,
    double? latitude,
    double? longitude,
    bool? isActive,
    String? instituteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportStop(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      stopName: stopName ?? this.stopName,
      stopAddress: stopAddress ?? this.stopAddress,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      pickupTime: pickupTime ?? this.pickupTime,
      dropTime: dropTime ?? this.dropTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isActive: isActive ?? this.isActive,
      instituteId: instituteId ?? this.instituteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
