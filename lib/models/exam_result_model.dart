class ExamResult {
  final String id;
  final String studentId;
  final String examId;
  final String subject;
  final double marks;
  final double totalMarks;
  final String? grade;
  final String? remarks;
  final String status; // pending, submitted, graded
  final bool isPresent; // attendance status for the exam
  final String? teacherRemarks;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamResult({
    required this.id,
    required this.studentId,
    required this.examId,
    required this.subject,
    required this.marks,
    required this.totalMarks,
    this.grade,
    this.remarks,
    this.status = 'pending',
    this.isPresent = true,
    this.teacherRemarks,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) {
        final milliseconds = raw > 10000000000 ? raw : raw * 1000;
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
      if (raw is String) {
        final asNumber = int.tryParse(raw);
        if (asNumber != null) {
          final milliseconds =
              asNumber > 10000000000 ? asNumber : asNumber * 1000;
          return DateTime.fromMillisecondsSinceEpoch(milliseconds);
        }
        return DateTime.tryParse(raw) ?? DateTime.now();
      }
      return DateTime.now();
    }

    bool parsePresent(dynamic isPresentRaw, dynamic isAbsentRaw) {
      if (isPresentRaw is bool) return isPresentRaw;
      if (isPresentRaw is int) return isPresentRaw == 1;
      if (isPresentRaw is String) return isPresentRaw.toLowerCase() == 'true';
      if (isAbsentRaw is int) return isAbsentRaw == 0;
      if (isAbsentRaw is bool) return !isAbsentRaw;
      return true;
    }

    return ExamResult(
      id: json['id'] ?? json['_id'] ?? '',
      studentId: json['student_id'] ?? json['studentId'] ?? '',
      examId: json['exam_id'] ?? json['examId'] ?? '',
      subject: json['subject'] ?? json['exam_subject'] ?? '',
      marks: ((json['marks'] ?? 0) as num).toDouble(),
      totalMarks:
          ((json['total_marks'] ?? json['totalMarks'] ?? 0) as num).toDouble(),
      grade: json['grade'],
      remarks: json['remarks'],
      status: json['status'] ?? (json['is_absent'] == 1 ? 'absent' : 'graded'),
      isPresent: parsePresent(json['isPresent'], json['is_absent']),
      teacherRemarks: json['teacher_remarks'] ?? json['teacherRemarks'],
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'exam_id': examId,
      'subject': subject,
      'marks': marks,
      'total_marks': totalMarks,
      'grade': grade,
      'remarks': remarks,
      'status': status,
      'is_absent': isPresent ? 0 : 1,
      'teacher_remarks': teacherRemarks,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  // Calculate percentage
  double get percentage => totalMarks > 0 ? (marks / totalMarks) * 100 : 0;

  // Calculate grade if not provided
  String get calculatedGrade {
    if (grade != null) return grade!;
    final percentage = this.percentage;
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B+';
    if (percentage >= 60) return 'B';
    if (percentage >= 50) return 'C+';
    if (percentage >= 40) return 'C';
    return 'F';
  }

  ExamResult copyWith({
    String? id,
    String? studentId,
    String? examId,
    String? subject,
    double? marks,
    double? totalMarks,
    String? grade,
    String? remarks,
    String? status,
    bool? isPresent,
    String? teacherRemarks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      examId: examId ?? this.examId,
      subject: subject ?? this.subject,
      marks: marks ?? this.marks,
      totalMarks: totalMarks ?? this.totalMarks,
      grade: grade ?? this.grade,
      remarks: remarks ?? this.remarks,
      status: status ?? this.status,
      isPresent: isPresent ?? this.isPresent,
      teacherRemarks: teacherRemarks ?? this.teacherRemarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
