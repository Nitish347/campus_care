class Teacher {
  final String id;
  final String teacherId;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String department;
  final String qualification;
  final DateTime joinDate;
  final List<String> subjects;
  final List<String> classes;
  final String address;
  final double salary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Teacher({
    required this.id,
    required this.teacherId,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.department,
    required this.qualification,
    required this.joinDate,
    this.subjects = const [],
    this.classes = const [],
    required this.address,
    required this.salary,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? '',
      teacherId: json['teacherId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      department: json['department'] ?? '',
      qualification: json['qualification'] ?? '',
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      subjects: List<String>.from(json['subjects'] ?? []),
      classes: List<String>.from(json['classes'] ?? []),
      address: json['address'] ?? '',
      salary: (json['salary'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'department': department,
      'qualification': qualification,
      'joinDate': joinDate.toIso8601String(),
      'subjects': subjects,
      'classes': classes,
      'address': address,
      'salary': salary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Teacher copyWith({
    String? id,
    String? teacherId,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? department,
    String? qualification,
    DateTime? joinDate,
    List<String>? subjects,
    List<String>? classes,
    String? address,
    double? salary,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Teacher(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      department: department ?? this.department,
      qualification: qualification ?? this.qualification,
      joinDate: joinDate ?? this.joinDate,
      subjects: subjects ?? this.subjects,
      classes: classes ?? this.classes,
      address: address ?? this.address,
      salary: salary ?? this.salary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}