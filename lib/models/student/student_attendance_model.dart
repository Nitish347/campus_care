class StudentAttendanceModel {
  final String id;
  final DateTime dateTime;
  final String status; // present, absent, late, excused
  final String userId;
  final String type; // daily, exam, event, etc.
  final String? remark;
  final String markedBy; // teacher/admin ID

  StudentAttendanceModel({
    required this.id,
    required this.dateTime,
    required this.status,
    required this.userId,
    required this.type,
    this.remark,
    required this.markedBy,
  });

  factory StudentAttendanceModel.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceModel(
      id: json['id'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? '',
      remark: json['remark'],
      markedBy: json['markedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'userId': userId,
      'type': type,
      'remark': remark,
      'markedBy': markedBy,
    };
  }

  StudentAttendanceModel copyWith({
    String? id,
    DateTime? dateTime,
    String? status,
    String? userId,
    String? type,
    String? remark,
    String? markedBy,
  }) {
    return StudentAttendanceModel(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      remark: remark ?? this.remark,
      markedBy: markedBy ?? this.markedBy,
    );
  }
}

