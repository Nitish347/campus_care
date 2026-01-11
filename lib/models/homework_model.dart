class HomeWorkModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherId;
  final String classId;
  final String section;
  final List<String> assignedStudents;
  final DateTime dueDate;
  final DateTime createdAt;
  final List<String> attachments;
  final String priority; // high, medium, low
  final double? totalMarks;

  HomeWorkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherId,
    required this.classId,
    required this.section,
    required this.assignedStudents,
    required this.dueDate,
    required this.createdAt,
    this.attachments = const [],
    this.priority = 'medium',
    this.totalMarks,
  });

  factory HomeWorkModel.fromJson(Map<String, dynamic> json) {
    return HomeWorkModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      teacherId: json['teacherId'] ?? '',
      classId: json['classId'] ?? '',
      section: json['section'] ?? '',
      assignedStudents: List<String>.from(json['assignedStudents'] ?? []),
      dueDate:
          DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      attachments: List<String>.from(json['attachments'] ?? []),
      priority: json['priority'] ?? 'medium',
      totalMarks: json['totalMarks']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacherId': teacherId,
      'classId': classId,
      'section': section,
      'assignedStudents': assignedStudents,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'attachments': attachments,
      'priority': priority,
      'totalMarks': totalMarks,
    };
  }

  HomeWorkModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? teacherId,
    String? classId,
    String? section,
    List<String>? assignedStudents,
    DateTime? dueDate,
    DateTime? createdAt,
    List<String>? attachments,
    String? priority,
    double? totalMarks,
  }) {
    return HomeWorkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      assignedStudents: assignedStudents ?? this.assignedStudents,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      attachments: attachments ?? this.attachments,
      priority: priority ?? this.priority,
      totalMarks: totalMarks ?? this.totalMarks,
    );
  }
}
