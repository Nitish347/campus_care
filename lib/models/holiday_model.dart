class HolidayModel {
  final String id;
  final String name;
  final DateTime date;
  final String type;
  final String? description;
  final bool isActive;

  const HolidayModel({
    required this.id,
    required this.name,
    required this.date,
    required this.type,
    this.description,
    this.isActive = true,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    return HolidayModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      date: _parseDate(json['date']),
      type: (json['type'] ?? 'Other').toString(),
      description: json['description']?.toString(),
      isActive: json['is_active'] == 1 || json['isActive'] == true,
    );
  }

  static DateTime _parseDate(dynamic raw) {
    if (raw is int) {
      final ms = raw > 10000000000 ? raw : raw * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    if (raw is String) {
      final asInt = int.tryParse(raw);
      if (asInt != null) {
        final ms = asInt > 10000000000 ? asInt : asInt * 1000;
        return DateTime.fromMillisecondsSinceEpoch(ms);
      }
      return DateTime.tryParse(raw) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    final localDate = DateTime(date.year, date.month, date.day);
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'date': localDate.millisecondsSinceEpoch ~/ 1000,
      'type': type,
      'description': description,
      'is_active': isActive ? 1 : 0,
    };
  }

  bool isSameDate(DateTime other) {
    return date.year == other.year &&
        date.month == other.month &&
        date.day == other.day;
  }
}
