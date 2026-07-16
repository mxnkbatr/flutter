import 'package:shared_preferences/shared_preferences.dart';

class AuthProfileCacheData {
  const AuthProfileCacheData({
    this.role,
    this.userId,
    this.userName,
  });

  final String? role;
  final String? userId;
  final String? userName;
}

/// Persists role/userId for offline session restore after /auth/me network errors.
class AuthProfileCache {
  AuthProfileCache._();

  static const _roleKey = 'sacred_user_role';
  static const _userIdKey = 'sacred_user_id';
  static const _userNameKey = 'sacred_user_name';

  static Future<void> save({
    String? role,
    String? userId,
    String? userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (role != null && role.isNotEmpty) {
      await prefs.setString(_roleKey, role);
    } else {
      await prefs.remove(_roleKey);
    }
    if (userId != null && userId.isNotEmpty) {
      await prefs.setString(_userIdKey, userId);
    } else {
      await prefs.remove(_userIdKey);
    }
    if (userName != null && userName.isNotEmpty) {
      await prefs.setString(_userNameKey, userName);
    } else {
      await prefs.remove(_userNameKey);
    }
  }

  static Future<AuthProfileCacheData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_roleKey);
    final userId = prefs.getString(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    if (role == null && userId == null && userName == null) return null;
    return AuthProfileCacheData(role: role, userId: userId, userName: userName);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
  }
}
