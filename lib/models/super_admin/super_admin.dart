class SuperAdmin {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final bool isEmailVerified;
  final String? otp;
  final DateTime? otpExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  SuperAdmin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory SuperAdmin.fromJson(Map<String, dynamic> json) {
    return SuperAdmin(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
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
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'isEmailVerified': isEmailVerified,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SuperAdmin copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    bool? isEmailVerified,
    String? otp,
    DateTime? otpExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SuperAdmin(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
