class Student {
  final String id;
  final String studentId;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final DateTime dateOfBirth;
  final String gender;
  final String address;
  final String classId;
  final String section;
  final DateTime admissionDate;
  final String guardianName;
  final String guardianPhone;
  final String guardianEmail;
  final String? guardianRelation;
  final String bloodGroup;
  final String? medicalInfo;
  final List<String> documents;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Student({
    required this.id,
    required this.studentId,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.classId,
    required this.section,
    required this.admissionDate,
    required this.guardianName,
    required this.guardianPhone,
    required this.guardianEmail,
    this.guardianRelation,
    required this.bloodGroup,
    this.medicalInfo,
    this.documents = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      dateOfBirth: DateTime.parse(json['dateOfBirth'] ?? DateTime.now().toIso8601String()),
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      classId: json['classId'] ?? '',
      section: json['section'] ?? '',
      admissionDate: DateTime.parse(json['admissionDate'] ?? DateTime.now().toIso8601String()),
      guardianName: json['guardianName'] ?? '',
      guardianPhone: json['guardianPhone'] ?? '',
      guardianEmail: json['guardianEmail'] ?? '',
      guardianRelation: json['guardianRelation'],
      bloodGroup: json['bloodGroup'] ?? '',
      medicalInfo: json['medicalInfo'],
      documents: List<String>.from(json['documents'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'address': address,
      'classId': classId,
      'section': section,
      'admissionDate': admissionDate.toIso8601String(),
      'guardianName': guardianName,
      'guardianPhone': guardianPhone,
      'guardianEmail': guardianEmail,
      'guardianRelation': guardianRelation,
      'bloodGroup': bloodGroup,
      'medicalInfo': medicalInfo,
      'documents': documents,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Student copyWith({
    String? id,
    String? studentId,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    DateTime? dateOfBirth,
    String? gender,
    String? address,
    String? classId,
    String? section,
    DateTime? admissionDate,
    String? guardianName,
    String? guardianPhone,
    String? guardianEmail,
    String? guardianRelation,
    String? bloodGroup,
    String? medicalInfo,
    List<String>? documents,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Student(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      admissionDate: admissionDate ?? this.admissionDate,
      guardianName: guardianName ?? this.guardianName,
      guardianPhone: guardianPhone ?? this.guardianPhone,
      guardianEmail: guardianEmail ?? this.guardianEmail,
      guardianRelation: guardianRelation ?? this.guardianRelation,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalInfo: medicalInfo ?? this.medicalInfo,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}