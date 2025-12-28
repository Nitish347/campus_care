class Guardian {
  final String name;
  final String phone;
  final String? email;
  final String? relation;

  Guardian({
    required this.name,
    required this.phone,
    this.email,
    this.relation,
  });

  factory Guardian.fromJson(Map<String, dynamic> json) {
    return Guardian(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      relation: json['relation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'relation': relation,
    };
  }

  Guardian copyWith({
    String? name,
    String? phone,
    String? email,
    String? relation,
  }) {
    return Guardian(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      relation: relation ?? this.relation,
    );
  }
}

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? password;
  final String? phone;
  final String enrollmentNumber;
  final String rollNumber;
  final String? class_;
  final String? section;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime? admissionDate;
  final String institute; // Institute ID reference
  final String? teacher; // Teacher ID reference (optional)
  final bool isEmailVerified;
  final String? otp;
  final DateTime? otpExpiry;
  final Guardian? guardian;
  final DateTime createdAt;
  final DateTime updatedAt;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.password,
    this.phone,
    required this.enrollmentNumber,
    required this.rollNumber,
    this.class_,
    this.section,
    this.gender,
    this.address,
    this.dateOfBirth,
    this.admissionDate,
    required this.institute,
    this.teacher,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    this.guardian,
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
      password: json['password'],
      phone: json['phone'],
      enrollmentNumber: json['enrollmentNumber'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      class_: json['class'],
      section: json['section'],
      gender: json['gender'],
      address: json['address'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      admissionDate: json['admissionDate'] != null
          ? DateTime.parse(json['admissionDate'])
          : null,
      institute: json['institute'] ?? '',
      teacher: json['teacher'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      otp: json['otp'],
      otpExpiry:
          json['otpExpiry'] != null ? DateTime.parse(json['otpExpiry']) : null,
      guardian:
          json['guardian'] != null ? Guardian.fromJson(json['guardian']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'phone': phone,
      'enrollmentNumber': enrollmentNumber,
      'rollNumber': rollNumber,
      'class': class_,
      'section': section,
      'gender': gender,
      'address': address,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'admissionDate': admissionDate?.toIso8601String(),
      'institute': institute,
      'teacher': teacher,
      'isEmailVerified': isEmailVerified,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'guardian': guardian?.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
    if (id.isNotEmpty) {
      data['_id'] = id;
    }
    return data;
  }

  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? password,
    String? phone,
    String? enrollmentNumber,
    String? rollNumber,
    String? class_,
    String? section,
    String? gender,
    String? address,
    DateTime? dateOfBirth,
    DateTime? admissionDate,
    String? institute,
    String? teacher,
    bool? isEmailVerified,
    String? otp,
    DateTime? otpExpiry,
    Guardian? guardian,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      enrollmentNumber: enrollmentNumber ?? this.enrollmentNumber,
      rollNumber: rollNumber ?? this.rollNumber,
      class_: class_ ?? this.class_,
      section: section ?? this.section,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      admissionDate: admissionDate ?? this.admissionDate,
      institute: institute ?? this.institute,
      teacher: teacher ?? this.teacher,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      guardian: guardian ?? this.guardian,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
