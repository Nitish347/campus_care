class NoticeModel {
  final String id;
  final String title;
  final String description;
  final String issuedBy; // teacher/admin ID
  final List<String>? targetedClassId;
  final List<String>? targetSections;
  final DateTime issuedDate;
  final DateTime? expiryDate;
  final String priority; // low, medium, high
  final List<String>? attachment; // file paths or URLs

  NoticeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.issuedBy,
    this.targetedClassId,
    this.targetSections,
    required this.issuedDate,
    this.expiryDate,
    required this.priority,
    this.attachment,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    return NoticeModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      issuedBy: json['issuedBy'] ?? '',
      targetedClassId: json['targetedClassId'] != null
          ? List<String>.from(json['targetedClassId'])
          : null,
      targetSections: json['targetSections'] != null
          ? List<String>.from(json['targetSections'])
          : null,
      issuedDate: DateTime.parse(json['issuedDate'] ?? DateTime.now().toIso8601String()),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      priority: json['priority'] ?? 'medium',
      attachment: json['attachment'] != null
          ? List<String>.from(json['attachment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'issuedBy': issuedBy,
      'targetedClassId': targetedClassId,
      'targetSections': targetSections,
      'issuedDate': issuedDate.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'priority': priority,
      'attachment': attachment,
    };
  }

  NoticeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? issuedBy,
    List<String>? targetedClassId,
    List<String>? targetSections,
    DateTime? issuedDate,
    DateTime? expiryDate,
    String? priority,
    List<String>? attachment,
  }) {
    return NoticeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      issuedBy: issuedBy ?? this.issuedBy,
      targetedClassId: targetedClassId ?? this.targetedClassId,
      targetSections: targetSections ?? this.targetSections,
      issuedDate: issuedDate ?? this.issuedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      priority: priority ?? this.priority,
      attachment: attachment ?? this.attachment,
    );
  }
}

