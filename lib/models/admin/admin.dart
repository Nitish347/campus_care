class Admin {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? profileImageUrl;

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
    this.profileImageUrl,
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
    T? getValue<T>(String camelCase, String snakeCase) {
      return (json[snakeCase] ?? json[camelCase]) as T?;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(
            value > 10000000000 ? value : value * 1000);
      }
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      return false;
    }

    return Admin(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: getValue('firstName', 'first_name') ?? '',
      lastName: getValue('lastName', 'last_name') ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      profileImageUrl: getValue('profileImageUrl', 'profile_image_url'),
      instituteName: getValue('instituteName', 'institute_name') ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'],
      website: json['website'],
      establishedYear: getValue('establishedYear', 'established_year'),
      isEmailVerified:
          parseBool(getValue('isEmailVerified', 'is_email_verified')),
      otp: json['otp'],
      otpExpiry: parseDate(getValue('otpExpiry', 'otp_expiry')),
      isActive: json.containsKey('isActive') || json.containsKey('is_active')
          ? parseBool(getValue('isActive', 'is_active'))
          : true,
      lastLogin: parseDate(getValue('lastLogin', 'last_login')),
      createdAt:
          parseDate(getValue('createdAt', 'created_at')) ?? DateTime.now(),
      updatedAt:
          parseDate(getValue('updatedAt', 'updated_at')) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'institute_name': instituteName,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'pincode': pincode,
      'website': website,
      'established_year': establishedYear,
      'is_email_verified': isEmailVerified ? 1 : 0,
      'otp': otp,
      'otp_expiry':
          otpExpiry != null ? otpExpiry!.millisecondsSinceEpoch ~/ 1000 : null,
      'is_active': isActive ? 1 : 0,
      'last_login':
          lastLogin != null ? lastLogin!.millisecondsSinceEpoch ~/ 1000 : null,
    };
  }

  Admin copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? profileImageUrl,
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
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
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
