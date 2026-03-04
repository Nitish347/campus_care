class NoticeModel {
  final String id;
  final String title;
  final String description; // maps to DB 'content'
  final String issuedBy; // maps to DB 'author_id'
  final List<String>? targetedClassId; // maps to DB 'target_classes' (JSON)
  final List<String>? targetSections; // maps to DB 'target_audience' (JSON)
  final DateTime issuedDate; // maps to DB 'publish_date' (unix)
  final DateTime? expiryDate; // maps to DB 'expiry_date' (unix)
  final String priority; // 'low', 'normal', 'high' — matches DB CHECK
  final List<String>? attachment; // maps to DB 'attachments' (JSON)
  final String? type; // 'general', 'urgent', 'event', 'holiday'

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
    this.type,
  });

  factory NoticeModel.fromJson(Map<String, dynamic> json) {
    // Helper: parse unix timestamp int OR ISO string to DateTime
    DateTime parseDate(dynamic raw, DateTime fallback) {
      if (raw == null) return fallback;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      if (raw is String) return DateTime.tryParse(raw) ?? fallback;
      return fallback;
    }

    DateTime? parseDateNullable(dynamic raw) {
      if (raw == null) return null;
      if (raw is int) return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      if (raw is String) {
        final parsed = DateTime.tryParse(raw);
        return parsed;
      }
      return null;
    }

    // Helper: parse JSON array field (may be List or JSON string)
    List<String>? parseStringList(dynamic raw) {
      if (raw == null) return null;
      if (raw is List) return List<String>.from(raw);
      return null;
    }

    // DB uses 'content', frontend uses 'description'
    final description = json['content'] ?? json['description'] ?? '';
    // DB uses 'author_id', frontend uses 'issuedBy'
    final issuedBy = json['author_id'] ?? json['issuedBy'] ?? '';
    // DB uses 'publish_date' (unix), frontend uses 'issuedDate'
    final issuedDate = parseDate(
      json['publish_date'] ?? json['issuedDate'],
      DateTime.now(),
    );
    // DB uses 'expiry_date' (unix), frontend uses 'expiryDate'
    final expiryDate = parseDateNullable(
      json['expiry_date'] ?? json['expiryDate'],
    );
    // DB uses 'target_classes' (JSON array), frontend uses 'targetedClassId'
    final targetedClassId = parseStringList(
      json['target_classes'] ?? json['targetedClassId'],
    );
    // DB uses 'target_audience' (JSON array), frontend uses 'targetSections'
    final targetSections = parseStringList(
      json['target_audience'] ?? json['targetSections'],
    );
    // DB uses 'attachments' (JSON array), frontend uses 'attachment'
    final attachment = parseStringList(
      json['attachments'] ?? json['attachment'],
    );

    // DB priority is 'normal', frontend may show 'medium' — normalise at read
    String priority = json['priority'] ?? 'normal';
    if (priority == 'medium') priority = 'normal';

    return NoticeModel(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      description: description,
      issuedBy: issuedBy,
      targetedClassId: targetedClassId,
      targetSections: targetSections,
      issuedDate: issuedDate,
      expiryDate: expiryDate,
      priority: priority,
      attachment: attachment,
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': description, // DB column name
      'author_id': issuedBy, // DB column name
      'target_classes':
          targetedClassId, // DB column name (BaseRepository serialises to JSON)
      'target_audience': targetSections, // DB column name
      'publish_date': issuedDate.millisecondsSinceEpoch ~/ 1000, // unix
      if (expiryDate != null)
        'expiry_date': expiryDate!.millisecondsSinceEpoch ~/ 1000,
      'priority': priority, // 'low', 'normal', 'high'
      'attachments': attachment, // DB column name
      if (type != null) 'type': type,
      'title': title,
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
    String? type,
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
      type: type ?? this.type,
    );
  }
}
