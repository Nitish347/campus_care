class ExamModel {
  final String id;
  final String examTypeId; // Link to ExamType
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
    required this.examTypeId,
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
    // exam_date comes as Unix timestamp (int) from D1
    DateTime parseExamDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    DateTime parseTs(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return ExamModel(
      id: json['id'] ?? json['_id'] ?? '',
      examTypeId: json['exam_type_id'] ?? json['examTypeId'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'quiz',
      subject: json['subject'] ?? '',
      classId: json['class_id'] ?? json['classId'] ?? '',
      section: json['section'] ?? '',
      teacherId: json['teacher_id'] ?? json['teacherId'] ?? '',
      totalMarks:
          ((json['total_marks'] ?? json['totalMarks'] ?? 0) as num).toDouble(),
      durationMinutes: json['duration_minutes'] ?? json['durationMinutes'],
      examDate: parseExamDate(json['exam_date'] ?? json['examDate']),
      instructions: json['instructions'],
      syllabus: json['syllabus'],
      createdAt: parseTs(json['created_at'] ?? json['createdAt']),
      updatedAt: parseTs(json['updated_at'] ?? json['updatedAt']),
      isActive: (json['is_active'] ?? json['isActive'] ?? 1) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exam_type_id': examTypeId,
      'name': name,
      'type': type,
      'subject': subject,
      'class_id': classId,
      'section': section,
      'teacher_id': teacherId,
      'total_marks': totalMarks,
      'duration_minutes': durationMinutes,
      'exam_date': examDate.millisecondsSinceEpoch ~/ 1000,
      'instructions': instructions,
      'syllabus': syllabus,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
      'is_active': isActive ? 1 : 0,
    };
  }

  ExamModel copyWith({
    String? id,
    String? examTypeId,
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
      examTypeId: examTypeId ?? this.examTypeId,
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
