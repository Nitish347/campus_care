class HomeWorkModel {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String teacherId;
  final List<String> assignedStudents;
  final DateTime dueDate;
  final DateTime createdAt;

  HomeWorkModel({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.teacherId,
    required this.assignedStudents,
    required this.dueDate,
    required this.createdAt,
  });

  factory HomeWorkModel.fromJson(Map<String, dynamic> json) {
    return HomeWorkModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      subject: json['subject'] ?? '',
      teacherId: json['teacherId'] ?? '',
      assignedStudents: List<String>.from(json['assignedStudents'] ?? []),
      dueDate: DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'subject': subject,
      'teacherId': teacherId,
      'assignedStudents': assignedStudents,
      'dueDate': dueDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  HomeWorkModel copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    String? teacherId,
    List<String>? assignedStudents,
    DateTime? dueDate,
    DateTime? createdAt,
  }) {
    return HomeWorkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      assignedStudents: assignedStudents ?? this.assignedStudents,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

