class ExamTypeModel {
  final String id;
  final String name;
  final String? description;
  final int? weightage; // percentage
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExamTypeModel({
    required this.id,
    required this.name,
    this.description,
    this.weightage,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExamTypeModel.fromJson(Map<String, dynamic> json) {
    DateTime parseTs(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    return ExamTypeModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      weightage: json['weightage'] as int?,
      isActive: (json['is_active'] ?? json['isActive'] ?? 1) == 1,
      createdAt: parseTs(json['created_at'] ?? json['createdAt']),
      updatedAt: parseTs(json['updated_at'] ?? json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      if (weightage != null) 'weightage': weightage,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch ~/ 1000,
      'updated_at': updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  ExamTypeModel copyWith({
    String? id,
    String? name,
    String? description,
    int? weightage,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExamTypeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      weightage: weightage ?? this.weightage,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper getter
  String get status => isActive ? 'Active' : 'Inactive';
}
