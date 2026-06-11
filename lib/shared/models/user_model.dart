enum UserRole { client, monk, admin }

UserRole roleFromString(String value) {
  switch (value.toLowerCase()) {
    case 'monk':
      return UserRole.monk;
    case 'admin':
      return UserRole.admin;
    default:
      return UserRole.client;
  }
}

String roleToString(UserRole role) {
  switch (role) {
    case UserRole.monk:
      return 'monk';
    case UserRole.admin:
      return 'admin';
    case UserRole.client:
      return 'client';
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.avatarUrl,
    this.phone,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? avatarUrl;
  final String? phone;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String? ?? '',
      role: roleFromString(json['role'] as String? ?? 'client'),
      avatarUrl: json['avatarUrl'] as String?,
      phone: json['phone'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': roleToString(role),
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
        if (phone != null) 'phone': phone,
      };
}
