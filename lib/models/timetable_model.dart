class TimeTableModel {
  final String id;
  final String classId;
  final String section;
  final Map<String, List<TimeTableItem>> weeklySchedule; // Key: day name (Monday, Tuesday, etc.)

  TimeTableModel({
    required this.id,
    required this.classId,
    required this.section,
    required this.weeklySchedule,
  });

  factory TimeTableModel.fromJson(Map<String, dynamic> json) {
    final scheduleMap = <String, List<TimeTableItem>>{};
    if (json['weeklySchedule'] != null) {
      (json['weeklySchedule'] as Map<String, dynamic>).forEach((key, value) {
        scheduleMap[key] = (value as List)
            .map((item) => TimeTableItem.fromJson(item as Map<String, dynamic>))
            .toList();
      });
    }

    return TimeTableModel(
      id: json['id'] ?? '',
      classId: json['classId'] ?? json['class'] ?? '',
      section: json['section'] ?? '',
      weeklySchedule: scheduleMap,
    );
  }

  Map<String, dynamic> toJson() {
    final scheduleMap = <String, dynamic>{};
    weeklySchedule.forEach((key, value) {
      scheduleMap[key] = value.map((item) => item.toJson()).toList();
    });

    return {
      'id': id,
      'classId': classId,
      'class': classId,
      'section': section,
      'weeklySchedule': scheduleMap,
    };
  }

  TimeTableModel copyWith({
    String? id,
    String? classId,
    String? section,
    Map<String, List<TimeTableItem>>? weeklySchedule,
  }) {
    return TimeTableModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      section: section ?? this.section,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
    );
  }
}

class TimeTableItem {
  final String period;
  final String subject;
  final String teacherId;
  final String? room;
  final String startTime;
  final String endTime;
  final String type; // lab, class, break, etc.

  TimeTableItem({
    required this.period,
    required this.subject,
    required this.teacherId,
    this.room,
    required this.startTime,
    required this.endTime,
    required this.type,
  });

  factory TimeTableItem.fromJson(Map<String, dynamic> json) {
    return TimeTableItem(
      period: json['period'] ?? '',
      subject: json['subject'] ?? '',
      teacherId: json['teacherId'] ?? '',
      room: json['room'],
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      type: json['type'] ?? 'class',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'period': period,
      'subject': subject,
      'teacherId': teacherId,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
    };
  }

  TimeTableItem copyWith({
    String? period,
    String? subject,
    String? teacherId,
    String? room,
    String? startTime,
    String? endTime,
    String? type,
  }) {
    return TimeTableItem(
      period: period ?? this.period,
      subject: subject ?? this.subject,
      teacherId: teacherId ?? this.teacherId,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
    );
  }
}

