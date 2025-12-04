class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentId;
  final String status; // pending, submitted, graded
  final DateTime? submittedAt;
  final String? submissionContent;
  final List<String> attachments;
  final double? marksObtained;
  final String? feedback;
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
    required this.createdAt,
    required this.updatedAt,
  });

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) {
    return HomeworkSubmission(
      id: json['id'] ?? '',
      homeworkId: json['homeworkId'] ?? '',
      studentId: json['studentId'] ?? '',
      status: json['status'] ?? 'pending',
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'])
          : null,
      submissionContent: json['submissionContent'],
      attachments: List<String>.from(json['attachments'] ?? []),
      marksObtained: json['marksObtained']?.toDouble(),
      feedback: json['feedback'],
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeworkId': homeworkId,
      'studentId': studentId,
      'status': status,
      'submittedAt': submittedAt?.toIso8601String(),
      'submissionContent': submissionContent,
      'attachments': attachments,
      'marksObtained': marksObtained,
      'feedback': feedback,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
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
