class Admin {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;

  // Institute Details
  final String instituteName;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final String? website;
  final int? establishedYear;

  final bool isEmailVerified;
  final String? otp;
  final DateTime? otpExpiry;
  final bool isActive;
  final DateTime? lastLogin;
  final DateTime createdAt;
  final DateTime updatedAt;

  Admin({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.instituteName,
    this.address,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.website,
    this.establishedYear,
    this.isEmailVerified = false,
    this.otp,
    this.otpExpiry,
    this.isActive = true,
    this.lastLogin,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      instituteName: json['instituteName'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      website: json['website'],
      establishedYear: json['establishedYear'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      otp: json['otp'],
      otpExpiry:
          json['otpExpiry'] != null ? DateTime.parse(json['otpExpiry']) : null,
      isActive: json['isActive'] ?? true,
      lastLogin:
          json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'instituteName': instituteName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'website': website,
      'establishedYear': establishedYear,
      'isEmailVerified': isEmailVerified,
      'otp': otp,
      'otpExpiry': otpExpiry?.toIso8601String(),
      'isActive': isActive,
      'lastLogin': lastLogin?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Admin copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? instituteName,
    String? address,
    String? city,
    String? state,
    String? country,
    String? pincode,
    String? website,
    int? establishedYear,
    bool? isEmailVerified,
    String? otp,
    DateTime? otpExpiry,
    bool? isActive,
    DateTime? lastLogin,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Admin(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      instituteName: instituteName ?? this.instituteName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pincode: pincode ?? this.pincode,
      website: website ?? this.website,
      establishedYear: establishedYear ?? this.establishedYear,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      otp: otp ?? this.otp,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      isActive: isActive ?? this.isActive,
      lastLogin: lastLogin ?? this.lastLogin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
