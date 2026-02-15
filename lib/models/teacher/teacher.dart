class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password; // Optional, only used during creation
  final String? phone;
  final String? address;
  final String? department;
  final DateTime? hireDate;
  final String institute; // Institute ID reference
  final bool isEmailVerified;
  final String? otp;
  final DateTime? otpExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.phone,
    this.address,
    this.department,
    this.hireDate,
    required this.institute,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Teacher.fromJson(Map<String, dynamic> json) {
    T? getValue<T>(String camelCase, String snakeCase) {
      return (json[snakeCase] ?? json[camelCase]) as T?;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is int)
        return DateTime.fromMillisecondsSinceEpoch(
            value > 10000000000 ? value : value * 1000);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return Teacher(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: getValue('firstName', 'first_name') ?? '',
      lastName: getValue('lastName', 'last_name') ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'],
      address: json['address'],
      department: json['department'],
      hireDate: parseDate(getValue('hireDate', 'hire_date')),
      institute: getValue('institute', 'institute_id') ?? '',
      isEmailVerified:
          parseBool(getValue('isEmailVerified', 'is_email_verified')),
      otp: json['otp'],
      otpExpiry: parseDate(getValue('otpExpiry', 'otp_expiry')),
      createdAt:
          parseDate(getValue('createdAt', 'created_at')) ?? DateTime.now(),
      updatedAt:
          parseDate(getValue('updatedAt', 'updated_at')) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'department': department,
      'hire_date':
          hireDate != null ? hireDate!.millisecondsSinceEpoch ~/ 1000 : null,
      'institute_id': institute,
      'is_email_verified': isEmailVerified ? 1 : 0,
      'otp': otp,
      'otp_expiry':
          otpExpiry != null ? otpExpiry!.millisecondsSinceEpoch ~/ 1000 : null,
    };
    // Only include id if it's not empty
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    // Only include password if it's set and not empty
    if (password != null && password!.isNotEmpty) {
      json['password'] = password!;
    }
    return json;
  }

  Teacher copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? address,
    String? department,
    DateTime? hireDate,
    String? institute,
    bool? isEmailVerified,
    String? otp,
    DateTime? otpExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      department: department ?? this.department,
      hireDate: hireDate ?? this.hireDate,
      institute: institute ?? this.institute,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
