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
  final String? routeId; // Transport route ID reference (optional)
  final String? profileImageUrl;
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
    this.routeId,
    this.profileImageUrl,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    this.guardian,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Student.fromJson(Map<String, dynamic> json) {
    // Helper to get value with fallback for both camelCase and snake_case
    T? getValue<T>(String camelCase, String snakeCase) {
      return (json[snakeCase] ?? json[camelCase]) as T?;
    }

    // Reconstruct guardian from flattened fields if any guardian field exists
    Guardian? guardian;
    if (json['guardian_name'] != null || json['guardianName'] != null) {
      guardian = Guardian(
        name: getValue('guardianName', 'guardian_name') ?? '',
        phone: getValue('guardianPhone', 'guardian_phone') ?? '',
        email: getValue('guardianEmail', 'guardian_email'),
        relation: getValue('guardianRelation', 'guardian_relation'),
      );
    } else if (json['guardian'] != null) {
      guardian = Guardian.fromJson(json['guardian']);
    }

    return Student(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: getValue('firstName', 'first_name') ?? '',
      lastName: getValue('lastName', 'last_name') ?? '',
      email: json['email'] ?? '',
      password: json['password'],
      phone: json['phone'],
      enrollmentNumber: getValue('enrollmentNumber', 'enrollment_number') ?? '',
      rollNumber: getValue('rollNumber', 'roll_number') ?? '',
      class_: json['class'],
      section: json['section'],
      gender: json['gender'],
      address: json['address'],
      dateOfBirth: _parseDate(getValue('dateOfBirth', 'date_of_birth')),
      admissionDate: _parseDate(getValue('admissionDate', 'admission_date')),
      institute: getValue('institute', 'institute_id') ?? '',
      teacher: getValue('teacher', 'teacher_id'),
      routeId: getValue('routeId', 'route_id') ??
          (json['transport_route'] is Map<String, dynamic>
              ? (json['transport_route']['id']?.toString())
              : null),
      profileImageUrl: getValue('profileImageUrl', 'profile_image_url'),
      isEmailVerified:
          _parseBool(getValue('isEmailVerified', 'is_email_verified')),
      otp: json['otp'],
      otpExpiry: _parseDate(getValue('otpExpiry', 'otp_expiry')),
      guardian: guardian,
      createdAt:
          _parseDate(getValue('createdAt', 'created_at')) ?? DateTime.now(),
      updatedAt:
          _parseDate(getValue('updatedAt', 'updated_at')) ?? DateTime.now(),
    );
  }

  // Helper to parse dates (handles both ISO strings and Unix timestamps)
  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // Helper to parse boolean (handles both bool and int 0/1)
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    return false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'enrollment_number': enrollmentNumber,
      'roll_number': rollNumber,
      'class': class_,
      'section': section,
      'gender': gender,
      'address': address,
      'date_of_birth': dateOfBirth?.millisecondsSinceEpoch,
      'admission_date': admissionDate?.millisecondsSinceEpoch,
      'institute_id': institute,
      'teacher_id': teacher,
      'route_id': (routeId == null || routeId!.isEmpty) ? null : routeId,
      'profile_image_url': profileImageUrl,
      'is_email_verified': isEmailVerified ? 1 : 0,
      'otp': otp,
      'otp_expiry': otpExpiry?.millisecondsSinceEpoch,
    };

    // Only include password if it's not null and not empty
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }

    // Add guardian fields separately if guardian exists
    if (guardian != null) {
      data['guardian_name'] = guardian!.name;
      data['guardian_phone'] = guardian!.phone;
      data['guardian_email'] = guardian!.email;
      data['guardian_relation'] = guardian!.relation;
    }

    if (id.isNotEmpty) {
      data['id'] = id;
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
    String? routeId,
    String? profileImageUrl,
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
      routeId: routeId ?? this.routeId,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      guardian: guardian ?? this.guardian,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
