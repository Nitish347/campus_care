class ExamResult {
  final String id;
  final String studentId;
  final String examId;
  final String subject;
  final double marks;
  final double totalMarks;
  final String? grade;
  final String? remarks;
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      examId: json['examId'] ?? '',
      subject: json['subject'] ?? '',
      marks: (json['marks'] ?? 0).toDouble(),
      totalMarks: (json['totalMarks'] ?? 0).toDouble(),
      grade: json['grade'],
      remarks: json['remarks'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'examId': examId,
      'subject': subject,
      'marks': marks,
      'totalMarks': totalMarks,
      'grade': grade,
      'remarks': remarks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

