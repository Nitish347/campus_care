class Institute {
  final String id;
  final String name;
  final String code;
  final String email;
  final String phone;
  final String address;
  final String? logo;
  final String? website;
  final DateTime? establishedDate;
  final String? affiliationNumber;

  // Subscription details
  final String subscriptionPlan; // 'basic', 'standard', 'premium'
  final String subscriptionStatus; // 'active', 'expired', 'trial', 'suspended'
  final DateTime subscriptionStartDate;
  final DateTime subscriptionEndDate;

  // Statistics
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;

  // Contact person
  final String contactPersonName;
  final String contactPersonEmail;
  final String contactPersonPhone;

  // Status
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  Institute({
    required this.id,
    required this.name,
    required this.code,
    required this.email,
    required this.phone,
    required this.address,
    this.logo,
    this.website,
    this.establishedDate,
    this.affiliationNumber,
    required this.subscriptionPlan,
    required this.subscriptionStatus,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalClasses = 0,
    required this.contactPersonName,
    required this.contactPersonEmail,
    required this.contactPersonPhone,
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Institute.fromJson(Map<String, dynamic> json) {
    return Institute(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      logo: json['logo'],
      website: json['website'],
      establishedDate: json['establishedDate'] != null
          ? DateTime.parse(json['establishedDate'])
          : null,
      affiliationNumber: json['affiliationNumber'],
      subscriptionPlan: json['subscriptionPlan'] ?? 'basic',
      subscriptionStatus: json['subscriptionStatus'] ?? 'trial',
      subscriptionStartDate: DateTime.parse(
          json['subscriptionStartDate'] ?? DateTime.now().toIso8601String()),
      subscriptionEndDate: DateTime.parse(
          json['subscriptionEndDate'] ?? DateTime.now().toIso8601String()),
      totalStudents: json['totalStudents'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      contactPersonName: json['contactPersonName'] ?? '',
      contactPersonEmail: json['contactPersonEmail'] ?? '',
      contactPersonPhone: json['contactPersonPhone'] ?? '',
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
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
      'code': code,
      'email': email,
      'phone': phone,
      'address': address,
      'logo': logo,
      'website': website,
      'establishedDate': establishedDate?.toIso8601String(),
      'affiliationNumber': affiliationNumber,
      'subscriptionPlan': subscriptionPlan,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionStartDate': subscriptionStartDate.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate.toIso8601String(),
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'contactPersonName': contactPersonName,
      'contactPersonEmail': contactPersonEmail,
      'contactPersonPhone': contactPersonPhone,
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Institute copyWith({
    String? id,
    String? name,
    String? code,
    String? email,
    String? phone,
    String? address,
    String? logo,
    String? website,
    DateTime? establishedDate,
    String? affiliationNumber,
    String? subscriptionPlan,
    String? subscriptionStatus,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    int? totalStudents,
    int? totalTeachers,
    int? totalClasses,
    String? contactPersonName,
    String? contactPersonEmail,
    String? contactPersonPhone,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Institute(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logo: logo ?? this.logo,
      website: website ?? this.website,
      establishedDate: establishedDate ?? this.establishedDate,
      affiliationNumber: affiliationNumber ?? this.affiliationNumber,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalClasses: totalClasses ?? this.totalClasses,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonEmail: contactPersonEmail ?? this.contactPersonEmail,
      contactPersonPhone: contactPersonPhone ?? this.contactPersonPhone,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  bool get isSubscriptionExpiringSoon {
    final daysUntilExpiry =
        subscriptionEndDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry > 0;
  }

  bool get isSubscriptionExpired {
    return subscriptionEndDate.isBefore(DateTime.now());
  }

  String get subscriptionDaysRemaining {
    final days = subscriptionEndDate.difference(DateTime.now()).inDays;
    if (days < 0) return 'Expired';
    if (days == 0) return 'Expires today';
    if (days == 1) return '1 day remaining';
    return '$days days remaining';
  }
}
