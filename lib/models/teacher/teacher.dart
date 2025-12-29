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
    return Teacher(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'], // Usually not returned from backend
      phone: json['phone'],
      address: json['address'],
      department: json['department'],
      hireDate:
          json['hireDate'] != null ? DateTime.parse(json['hireDate']) : null,
      institute: json['institute'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      otp: json['otp'],
      otpExpiry:
          json['otpExpiry'] != null ? DateTime.parse(json['otpExpiry']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'address': address,
      'department': department,
      'hireDate': hireDate?.toIso8601String(),
      'institute': institute,
      'isEmailVerified': isEmailVerified,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    // Only include _id if it's not empty
    if (id.isNotEmpty) {
      json['_id'] = id;
    }
    // Only include password if it's set (for creation)
    if (password != null) {
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
