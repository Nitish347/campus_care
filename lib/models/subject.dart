class Subject {
  final String id;
  final String name;
  final String code;
  final String description;
  final String? classId;
  final String? teacherId;
  final String instituteId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.classId,
    this.teacherId,
    required this.instituteId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      classId: json['class_id'],
      teacherId: json['teacher_id'],
      instituteId: json['institute_id'] ?? '',
      isActive: (json['is_active'] ?? 1) == 1,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      'class_id': classId,
      'teacher_id': teacherId,
      'institute_id': instituteId,
      'is_active': isActive ? 1 : 0,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? classId,
    String? teacherId,
    String? instituteId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      instituteId: instituteId ?? this.instituteId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
