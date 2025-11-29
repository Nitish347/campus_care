class ExamTimeTable {
  final String id;
  final String session; // e.g., "2024-2025"
  final String examName;
  final List<ExamTimeTableItem> examTimeTable;

  ExamTimeTable({
    required this.id,
    required this.session,
    required this.examName,
    required this.examTimeTable,
  });

  factory ExamTimeTable.fromJson(Map<String, dynamic> json) {
    return ExamTimeTable(
      id: json['id'] ?? '',
      session: json['session'] ?? '',
      examName: json['examName'] ?? '',
      examTimeTable: (json['examTimeTable'] as List<dynamic>?)
              ?.map((item) => ExamTimeTableItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session': session,
      'examName': examName,
      'examTimeTable': examTimeTable.map((item) => item.toJson()).toList(),
    };
  }

  ExamTimeTable copyWith({
    String? id,
    String? session,
    String? examName,
    List<ExamTimeTableItem>? examTimeTable,
  }) {
    return ExamTimeTable(
      id: id ?? this.id,
      session: session ?? this.session,
      examName: examName ?? this.examName,
      examTimeTable: examTimeTable ?? this.examTimeTable,
    );
  }
}

class ExamTimeTableItem {
  final String id;
  final DateTime dateTime;
  final String subject;
  final bool isFirstHalf; // true for first half, false for second half

  ExamTimeTableItem({
    required this.id,
    required this.dateTime,
    required this.subject,
    required this.isFirstHalf,
  });

  factory ExamTimeTableItem.fromJson(Map<String, dynamic> json) {
    return ExamTimeTableItem(
      id: json['id'] ?? '',
      dateTime: DateTime.parse(json['dateTime'] ?? DateTime.now().toIso8601String()),
      subject: json['subject'] ?? '',
      isFirstHalf: json['isFirstHalf'] ?? json['firstHalf'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'subject': subject,
      'isFirstHalf': isFirstHalf,
      'firstHalf': isFirstHalf,
    };
  }

  ExamTimeTableItem copyWith({
    String? id,
    DateTime? dateTime,
    String? subject,
    bool? isFirstHalf,
  }) {
    return ExamTimeTableItem(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      subject: subject ?? this.subject,
      isFirstHalf: isFirstHalf ?? this.isFirstHalf,
    );
  }
}

