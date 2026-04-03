class TransportDriver {
  final String id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? alternatePhone;
  final String licenseNumber;
  final DateTime? licenseExpiry;
  final String? badgeNumber;
  final String? address;
  final bool isActive;
  final String instituteId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransportDriver({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.alternatePhone,
    required this.licenseNumber,
    this.licenseExpiry,
    this.badgeNumber,
    this.address,
    required this.isActive,
    required this.instituteId,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

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

  factory TransportDriver.fromJson(Map<String, dynamic> json) {
    return TransportDriver(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      firstName: (json['first_name'] ?? json['firstName'] ?? '').toString(),
      lastName: (json['last_name'] ?? json['lastName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      alternatePhone: json['alternate_phone']?.toString() ??
          json['alternatePhone']?.toString(),
      licenseNumber:
          (json['license_number'] ?? json['licenseNumber'] ?? '').toString(),
      licenseExpiry:
          _parseDate(json['license_expiry'] ?? json['licenseExpiry']),
      badgeNumber:
          json['badge_number']?.toString() ?? json['badgeNumber']?.toString(),
      address: json['address']?.toString(),
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
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'alternate_phone': alternatePhone,
      'license_number': licenseNumber,
      'license_expiry': licenseExpiry != null
          ? licenseExpiry!.millisecondsSinceEpoch ~/ 1000
          : null,
      'badge_number': badgeNumber,
      'address': address,
      'is_active': isActive ? 1 : 0,
      'institute_id': instituteId,
    };
  }

  TransportDriver copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phone,
    String? alternatePhone,
    String? licenseNumber,
    DateTime? licenseExpiry,
    String? badgeNumber,
    String? address,
    bool? isActive,
    String? instituteId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransportDriver(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiry: licenseExpiry ?? this.licenseExpiry,
      badgeNumber: badgeNumber ?? this.badgeNumber,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      instituteId: instituteId ?? this.instituteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
