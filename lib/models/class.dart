class SchoolClass {
  final String id;
  final String name;
  final String grade;
  final List<String> sections;
  final String? teacherId;
  final int maxStudents;
  final List<String> subjects;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  SchoolClass({
    required this.id,
    required this.name,
    required this.grade,
    required this.sections,
    this.teacherId,
    this.maxStudents = 40,
    this.subjects = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory SchoolClass.fromJson(Map<String, dynamic> json) {
    return SchoolClass(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      sections: List<String>.from(json['sections'] ?? []),
      teacherId: json['teacherId'],
      maxStudents: json['maxStudents'] ?? 40,
      subjects: List<String>.from(json['subjects'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'sections': sections,
      'teacherId': teacherId,
      'maxStudents': maxStudents,
      'subjects': subjects,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
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
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      grade: grade ?? this.grade,
      sections: sections ?? this.sections,
      teacherId: teacherId ?? this.teacherId,
      maxStudents: maxStudents ?? this.maxStudents,
      subjects: subjects ?? this.subjects,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}