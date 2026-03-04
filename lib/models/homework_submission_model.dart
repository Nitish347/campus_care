import 'dart:convert';

class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentId;
  final String status; // pending, submitted, graded, late
  final DateTime? submittedAt;
  final String? submissionContent;
  final List<String> attachments;
  final double? marksObtained;
  final String? feedback;
  final String? gradedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  HomeworkSubmission({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    this.status = 'pending',
    this.submittedAt,
    this.submissionContent,
    this.attachments = const [],
    this.marksObtained,
    this.feedback,
    this.gradedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      // D1 stores dates as unix seconds (int)
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val * 1000);
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return List<String>.from(val);
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return List<String>.from(decoded);
        } catch (_) {}
      }
      return [];
    }

    return HomeworkSubmission(
      id: json['id'] ?? '',
      // D1 snake_case with camelCase fallback
      homeworkId: json['homework_id'] ?? json['homeworkId'] ?? '',
      studentId: json['student_id'] ?? json['studentId'] ?? '',
      status: json['status'] ?? 'pending',
      submittedAt: json['submitted_at'] != null
          ? parseDate(json['submitted_at'])
          : json['submittedAt'] != null
              ? parseDate(json['submittedAt'])
              : null,
      submissionContent: json['submission_text'] ??
          json['submissionContent'] ??
          json['submissionText'],
      attachments: parseList(json['attachments']),
      marksObtained:
          (json['marks_obtained'] ?? json['marksObtained'])?.toDouble(),
      feedback: json['feedback'],
      gradedBy: json['graded_by'] ?? json['gradedBy'],
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDate(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homework_id': homeworkId,
      'student_id': studentId,
      'status': status,
      if (submittedAt != null)
        'submitted_at': submittedAt!.millisecondsSinceEpoch ~/ 1000,
      if (submissionContent != null) 'submission_text': submissionContent,
      'attachments': jsonEncode(attachments),
      if (marksObtained != null) 'marks_obtained': marksObtained,
      if (feedback != null) 'feedback': feedback,
      if (gradedBy != null) 'graded_by': gradedBy,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  HomeworkSubmission copyWith({
    String? id,
    String? homeworkId,
    String? studentId,
    String? status,
    DateTime? submittedAt,
    String? submissionContent,
    List<String>? attachments,
    double? marksObtained,
    String? feedback,
    String? gradedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HomeworkSubmission(
      id: id ?? this.id,
      homeworkId: homeworkId ?? this.homeworkId,
      studentId: studentId ?? this.studentId,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      submissionContent: submissionContent ?? this.submissionContent,
      attachments: attachments ?? this.attachments,
      marksObtained: marksObtained ?? this.marksObtained,
      feedback: feedback ?? this.feedback,
      gradedBy: gradedBy ?? this.gradedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getter to check if submitted
  bool get isSubmitted => status == 'submitted' || status == 'graded';

  // Helper getter to check if graded
  bool get isGraded => status == 'graded';

  // Helper getter to check if pending
  bool get isPending => status == 'pending';
}
