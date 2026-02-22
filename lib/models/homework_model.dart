import 'dart:convert';

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

    return HomeWorkModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      // D1 snake_case with camelCase fallback
      teacherId: json['teacher_id'] ?? json['teacherId'] ?? '',
      classId: json['class_id'] ?? json['classId'] ?? '',
      section: json['section'] ?? '',
      assignedStudents:
          parseList(json['assigned_students'] ?? json['assignedStudents']),
      dueDate: parseDate(json['due_date'] ?? json['dueDate']),
      createdAt: parseDate(json['created_at'] ?? json['createdAt']),
      attachments: parseList(json['attachments']),
      priority: json['priority'] ?? 'medium',
      totalMarks: (json['total_marks'] ?? json['totalMarks'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacher_id': teacherId,
      'class_id': classId,
      'section': section,
      'assigned_students': jsonEncode(assignedStudents),
      'due_date': dueDate.millisecondsSinceEpoch ~/ 1000,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'attachments': jsonEncode(attachments),
      'priority': priority,
      if (totalMarks != null) 'total_marks': totalMarks,
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
