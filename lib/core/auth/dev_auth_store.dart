import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DevAuthUser {
  const DevAuthUser({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    this.role = 'client',
  });

  final String id;
  final String email;
  final String password;
  final String name;
  final String role;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'name': name,
        'role': role,
      };

  factory DevAuthUser.fromJson(Map<String, dynamic> json) {
    return DevAuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      role: json['role'] as String? ?? 'client',
    );
  }
}

class DevAuthStore {
  static const usersKey = 'dev_auth_users';
  static const defaultEmail = '12345678@test.com';
  static const defaultPassword = '12345678';
  static const defaultName = '12345678';

  Future<void> ensureSeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(usersKey);
    if (raw != null) return;

    await _saveUsers([
      const DevAuthUser(
        id: 'dev-user-1',
        email: defaultEmail,
        password: defaultPassword,
        name: defaultName,
      ),
    ]);
  }

  Future<List<DevAuthUser>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(usersKey);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => DevAuthUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveUsers(List<DevAuthUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  String tokenFor(DevAuthUser user) => 'dev_${user.id}';

  DevAuthUser? userFromToken(String token, List<DevAuthUser> users) {
    if (!token.startsWith('dev_')) return null;
    final id = token.substring(4);
    for (final user in users) {
      if (user.id == id) return user;
    }
    return null;
  }

  Future<DevAuthUser?> findByToken(String token) async {
    await ensureSeeded();
    return userFromToken(token, await _loadUsers());
  }

  Future<DevAuthUser?> login(String email, String password) async {
    await ensureSeeded();
    final users = await _loadUsers();
    final normalized = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == normalized &&
          user.password == password) {
        return user;
      }
    }
    return null;
  }

  Future<DevAuthUser> signup(String email, String password, String name) async {
    await ensureSeeded();
    final users = await _loadUsers();
    final normalized = email.trim().toLowerCase();
    if (users.any((u) => u.email.toLowerCase() == normalized)) {
      throw Exception('Энэ имэйлээр бүртгэл байна');
    }

    final user = DevAuthUser(
      id: 'dev-user-${users.length + 1}',
      email: normalized,
      password: password,
      name: name.trim(),
    );
    await _saveUsers([...users, user]);
    return user;
  }
}
