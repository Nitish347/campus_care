class MedicalRecordModel {
  final String id;
  final String userId;
  final DateTime checkupDate;
  final String checkupType;
  final List<HealthParameters> parameters;
  final String drName;
  final String? remark;
  final List<String> attachment; // file paths or URLs
  final DateTime createdAt;

  MedicalRecordModel({
    required this.id,
    required this.userId,
    required this.checkupDate,
    required this.checkupType,
    required this.parameters,
    required this.drName,
    this.remark,
    this.attachment = const [],
    required this.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      checkupDate: DateTime.parse(json['checkupDate'] ?? DateTime.now().toIso8601String()),
      checkupType: json['checkupType'] ?? '',
      parameters: (json['parameters'] as List<dynamic>?)
              ?.map((item) => HealthParameters.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      drName: json['drName'] ?? '',
      remark: json['remark'],
      attachment: List<String>.from(json['attachment'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'checkupDate': checkupDate.toIso8601String(),
      'checkupType': checkupType,
      'parameters': parameters.map((param) => param.toJson()).toList(),
      'drName': drName,
      'remark': remark,
      'attachment': attachment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MedicalRecordModel copyWith({
    String? id,
    String? userId,
    DateTime? checkupDate,
    String? checkupType,
    List<HealthParameters>? parameters,
    String? drName,
    String? remark,
    List<String>? attachment,
    DateTime? createdAt,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      checkupDate: checkupDate ?? this.checkupDate,
      checkupType: checkupType ?? this.checkupType,
      parameters: parameters ?? this.parameters,
      drName: drName ?? this.drName,
      remark: remark ?? this.remark,
      attachment: attachment ?? this.attachment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class HealthParameters {
  final String name;
  final String value;
  final String status; // normal, not normal, critical, etc.

  HealthParameters({
    required this.name,
    required this.value,
    required this.status,
  });

  factory HealthParameters.fromJson(Map<String, dynamic> json) {
    return HealthParameters(
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      status: json['status'] ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'status': status,
    };
  }

  HealthParameters copyWith({
    String? name,
    String? value,
    String? status,
  }) {
    return HealthParameters(
      name: name ?? this.name,
      value: value ?? this.value,
      status: status ?? this.status,
    );
  }
}

