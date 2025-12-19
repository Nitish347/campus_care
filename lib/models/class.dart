class SchoolClass {
  final String id;
  final String name;
  final String grade;
  final List<String> sections;
  final String? teacherId;
  final int maxStudents;
  final List<String> subjects;
  final String instituteId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolClass({
    required this.id,
    required this.name,
    required this.grade,
    required this.sections,
    this.teacherId,
    this.maxStudents = 40,
    this.subjects = const [],
    required this.instituteId,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      sections: List<String>.from(json['sections'] ?? []),
      teacherId: json['teacherId'],
      maxStudents: json['maxStudents'] ?? 40,
      subjects: List<String>.from(json['subjects'] ?? []),
      instituteId: json['instituteId'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'grade': grade,
      'sections': sections,
      'teacherId': teacherId,
      'maxStudents': maxStudents,
      'subjects': subjects,
      'instituteId': instituteId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  SchoolClass copyWith({
    String? id,
    String? name,
    String? grade,
    List<String>? sections,
    String? teacherId,
    int? maxStudents,
    List<String>? subjects,
    String? instituteId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      sections: sections ?? this.sections,
      teacherId: teacherId ?? this.teacherId,
      maxStudents: maxStudents ?? this.maxStudents,
      subjects: subjects ?? this.subjects,
      instituteId: instituteId ?? this.instituteId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
