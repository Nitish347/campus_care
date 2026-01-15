import 'package:intl/intl.dart';

class LunchModel {
  final String id;
  final String teacherId;
  final String studentId;
  final DateTime date;
  final String status; // 'Full Meal', 'Half Meal', 'Not Taken', 'Absent'
  final String classId;
  final String section;
  final String? remarks;
  final String markedBy;
  final DateTime markedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Optional populated fields from backend
  final Map<String, dynamic>? teacher;
  final Map<String, dynamic>? student;

  LunchModel({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.date,
    required this.status,
    required this.classId,
    required this.section,
    this.remarks,
    required this.markedBy,
    required this.markedAt,
    this.createdAt,
    this.updatedAt,
    this.teacher,
    this.student,
  });

  factory LunchModel.fromJson(Map<String, dynamic> json) {
    return LunchModel(
      id: json['_id'] ?? json['id'] ?? '',
      teacherId: json['teacherId'] is String
          ? json['teacherId']
          : json['teacherId']?['_id'] ?? '',
      studentId: json['studentId'] is String
          ? json['studentId']
          : json['studentId']?['_id'] ?? '',
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      status: json['status'] ?? 'Not Taken',
      classId: json['class'] ?? '',
      section: json['section'] ?? '',
      remarks: json['remarks'],
      markedBy: json['markedBy'] ?? '',
      markedAt: json['markedAt'] is String
          ? DateTime.parse(json['markedAt'])
          : DateTime.now(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      teacher: json['teacherId'] is Map ? json['teacherId'] : null,
      student: json['studentId'] is Map ? json['studentId'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'teacherId': teacherId,
      'studentId': studentId,
      'date': date.toIso8601String(),
      'status': status,
      'class': classId,
      'section': section,
      if (remarks != null) 'remarks': remarks,
      'markedBy': markedBy,
      'markedAt': markedAt.toIso8601String(),
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  LunchModel copyWith({
    String? id,
    String? teacherId,
    String? studentId,
    DateTime? date,
    String? status,
    String? classId,
    String? section,
    String? remarks,
    String? markedBy,
    DateTime? markedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? teacher,
    Map<String, dynamic>? student,
  }) {
    return LunchModel(
      id: id ?? this.id,
      teacherId: teacherId ?? this.teacherId,
      studentId: studentId ?? this.studentId,
      date: date ?? this.date,
      status: status ?? this.status,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      remarks: remarks ?? this.remarks,
      markedBy: markedBy ?? this.markedBy,
      markedAt: markedAt ?? this.markedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      teacher: teacher ?? this.teacher,
      student: student ?? this.student,
    );
  }

  // Helper getters
  String get studentFullName {
    if (student != null) {
      return '${student!['firstName']} ${student!['lastName']}';
    }
    return '';
  }

  String get teacherFullName {
    if (teacher != null) {
      return '${teacher!['firstName']} ${teacher!['lastName']}';
    }
    return '';
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get formattedTime => DateFormat('hh:mm a').format(markedAt);

  bool get isFullMeal => status == 'Full Meal';
  bool get isHalfMeal => status == 'Half Meal';
  bool get isNotTaken => status == 'Not Taken';
  bool get isAbsent => status == 'Absent';
}
