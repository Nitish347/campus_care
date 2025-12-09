class Admin {
  final String id;
  final String adminId;
  final String name;
  final String email;
  final String phone;
  final String? avatar;
  final String role; // e.g., 'Super Admin', 'Editor', 'Viewer'
  final List<String> permissions;
  final String? instituteId; // Links admin to specific institute
  final bool isSuperAdmin; // True for Campus Care super admins
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  Admin({
    required this.id,
    required this.adminId,
    required this.name,
    required this.email,
    required this.phone,
    this.avatar,
    required this.role,
    this.permissions = const [],
    this.instituteId,
    this.isSuperAdmin = false,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? '',
      adminId: json['adminId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatar: json['avatar'],
      role: json['role'] ?? 'Admin',
      permissions: List<String>.from(json['permissions'] ?? []),
      instituteId: json['instituteId'],
      isSuperAdmin: json['isSuperAdmin'] ?? false,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'adminId': adminId,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'permissions': permissions,
      'instituteId': instituteId,
      'isSuperAdmin': isSuperAdmin,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  Admin copyWith({
    String? id,
    String? adminId,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? role,
    List<String>? permissions,
    String? instituteId,
    bool? isSuperAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return Admin(
      id: id ?? this.id,
      adminId: adminId ?? this.adminId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      instituteId: instituteId ?? this.instituteId,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
