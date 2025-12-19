class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String enrollmentNumber;
  final String? class_;
  final String? section;
  final DateTime? dateOfBirth;
  final String institute; // Institute ID reference
  final String? teacher; // Teacher ID reference (optional)
  final bool isEmailVerified;
  final String? otp;
  final DateTime? otpExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.enrollmentNumber,
    this.class_,
    this.section,
    this.dateOfBirth,
    required this.institute,
    this.teacher,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      enrollmentNumber: json['enrollmentNumber'] ?? '',
      class_: json['class'],
      section: json['section'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      institute: json['institute'] ?? '',
      teacher: json['teacher'],
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
      'enrollmentNumber': enrollmentNumber,
      'class': class_,
      'section': section,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'institute': institute,
      'teacher': teacher,
      'isEmailVerified': isEmailVerified,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? enrollmentNumber,
    String? class_,
    String? section,
    DateTime? dateOfBirth,
    String? institute,
    String? teacher,
    bool? isEmailVerified,
    String? otp,
    DateTime? otpExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      class_: class_ ?? this.class_,
      section: section ?? this.section,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      institute: institute ?? this.institute,
      teacher: teacher ?? this.teacher,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
