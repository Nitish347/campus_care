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
    T? getValue<T>(String camelCase, String snakeCase) {
      return (json[snakeCase] ?? json[camelCase]) as T?;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is int)
        return DateTime.fromMillisecondsSinceEpoch(
            value > 10000000000 ? value : value * 1000);
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return SchoolClass(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      sections: List<String>.from(json['sections'] ?? []),
      teacherId: getValue('teacherId', 'teacher_id'),
      maxStudents: getValue('maxStudents', 'max_students') ?? 40,
      subjects: List<String>.from(json['subjects'] ?? []),
      instituteId: getValue('instituteId', 'institute_id') ?? '',
      isActive: parseBool(getValue('isActive', 'is_active')) || true,
      createdAt:
          parseDate(getValue('createdAt', 'created_at')) ?? DateTime.now(),
      updatedAt:
          parseDate(getValue('updatedAt', 'updated_at')) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'grade': grade,
      'sections': sections,
      'teacher_id': teacherId,
      'max_students': maxStudents,
      'subjects': subjects,
      'institute_id': instituteId,
      'is_active': isActive ? 1 : 0,
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
