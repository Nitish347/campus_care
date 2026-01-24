// /// Model for individual timetable entries (teacher's perspective)
// /// This represents a single class period in a teacher's schedule
// class TimetableEntry {
//   final String id;
//   final String day;
//   final String subject;
//   final String classId;
//   final String? className;
//   final String? section;
//   final String startTime;
//   final String endTime;
//   final String? period;
//   final String? room;
//   final String? type;
//   final String? teacherId;
//
//   TimetableEntry({
//     required this.id,
//     required this.day,
//     required this.subject,
//     required this.classId,
//     this.className,
//     this.section,
//     required this.startTime,
//     required this.endTime,
//     this.period,
//     this.room,
//     this.type,
//     this.teacherId,
//   });
//
//   factory TimetableEntry.fromJson(Map<String, dynamic> json) {
//     return TimetableEntry(
//       id: json['_id'] ?? json['id'] ?? '',
//       day: json['dayOfWeek'] ?? json['day'] ?? '',
//       subject: json['subject'] ?? '',
//       classId: json['classId'] ?? json['class'] ?? '',
//       className: json['className'],
//       section: json['section'],
//       startTime: json['startTime'] ?? '',
//       endTime: json['endTime'] ?? '',
//       period: json['period'],
//       room: json['room'],
//       type: json['type'] ?? 'class',
//       teacherId: json['teacherId'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'day': day,
//       'subject': subject,
//       'classId': classId,
//       'className': className,
//       'section': section,
//       'startTime': startTime,
//       'endTime': endTime,
//       'period': period,
//       'room': room,
//       'type': type,
//       'teacherId': teacherId,
//     };
//   }
//
//   TimetableEntry copyWith({
//     String? id,
//     String? day,
//     String? subject,
//     String? classId,
//     String? className,
//     String? section,
//     String? startTime,
//     String? endTime,
//     String? period,
//     String? room,
//     String? type,
//     String? teacherId,
//   }) {
//     return TimetableEntry(
//       id: id ?? this.id,
//       day: day ?? this.day,
//       subject: subject ?? this.subject,
//       classId: classId ?? this.classId,
//       className: className ?? this.className,
//       section: section ?? this.section,
//       startTime: startTime ?? this.startTime,
//       endTime: endTime ?? this.endTime,
//       period: period ?? this.period,
//       room: room ?? this.room,
//       type: type ?? this.type,
//       teacherId: teacherId ?? this.teacherId,
//     );
//   }
// }
