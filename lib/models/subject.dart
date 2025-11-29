class Subject {
  final String id;
  final String name;
  final String code;
  final String description;
  final String classId;
  final String? teacherId;
  final int credits;
  final String category;
  final List<String> syllabus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.classId,
    this.teacherId,
    required this.credits,
    required this.category,
    this.syllabus = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      classId: json['classId'] ?? '',
      teacherId: json['teacherId'],
      credits: json['credits'] ?? 1,
      category: json['category'] ?? '',
      syllabus: List<String>.from(json['syllabus'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'classId': classId,
      'teacherId': teacherId,
      'credits': credits,
      'category': category,
      'syllabus': syllabus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? classId,
    String? teacherId,
    int? credits,
    String? category,
    List<String>? syllabus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      classId: classId ?? this.classId,
      teacherId: teacherId ?? this.teacherId,
      credits: credits ?? this.credits,
      category: category ?? this.category,
      syllabus: syllabus ?? this.syllabus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}