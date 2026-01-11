class ExamTypeModel {
  final String id;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamTypeModel.fromJson(Map<String, dynamic> json) {
    return ExamTypeModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      startDate:
          DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate:
          DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ExamTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getters
  bool get isOngoing {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isUpcoming => DateTime.now().isBefore(startDate);

  bool get isCompleted => DateTime.now().isAfter(endDate);

  String get status {
    if (isOngoing) return 'Ongoing';
    if (isUpcoming) return 'Upcoming';
    return 'Completed';
  }
}
