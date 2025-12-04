class ExamModel {
  final String id;
  final String name;
  final String type; // quiz, mid-term, final, assignment
  final String subject;
  final String classId;
  final String section;
  final String teacherId;
  final double totalMarks;
  final int? durationMinutes;
  final DateTime examDate;
  final String? instructions;
  final String? syllabus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ExamModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subject,
    required this.classId,
    required this.section,
    required this.teacherId,
    required this.totalMarks,
    this.durationMinutes,
    required this.examDate,
    this.instructions,
    this.syllabus,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory ExamModel.fromJson(Map<String, dynamic> json) {
    return ExamModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'quiz',
      subject: json['subject'] ?? '',
      classId: json['classId'] ?? '',
      section: json['section'] ?? '',
      teacherId: json['teacherId'] ?? '',
      totalMarks: (json['totalMarks'] ?? 0).toDouble(),
      durationMinutes: json['durationMinutes'],
      examDate:
          DateTime.parse(json['examDate'] ?? DateTime.now().toIso8601String()),
      instructions: json['instructions'],
      syllabus: json['syllabus'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'subject': subject,
      'classId': classId,
      'section': section,
      'teacherId': teacherId,
      'totalMarks': totalMarks,
      'durationMinutes': durationMinutes,
      'examDate': examDate.toIso8601String(),
      'instructions': instructions,
      'syllabus': syllabus,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  ExamModel copyWith({
    String? id,
    String? name,
    String? type,
    String? subject,
    String? classId,
    String? section,
    String? teacherId,
    double? totalMarks,
    int? durationMinutes,
    DateTime? examDate,
    String? instructions,
    String? syllabus,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ExamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subject: subject ?? this.subject,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      teacherId: teacherId ?? this.teacherId,
      totalMarks: totalMarks ?? this.totalMarks,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      examDate: examDate ?? this.examDate,
      instructions: instructions ?? this.instructions,
      syllabus: syllabus ?? this.syllabus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // Helper getter to check if exam is upcoming
  bool get isUpcoming => examDate.isAfter(DateTime.now());

  // Helper getter to check if exam is completed
  bool get isCompleted => examDate.isBefore(DateTime.now());
}
