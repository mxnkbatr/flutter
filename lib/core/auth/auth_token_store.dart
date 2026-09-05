import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists JWT across app restarts.
///
/// Web: [SharedPreferences] (localStorage) is the reliable source of truth —
/// [FlutterSecureStorage] alone often fails to restore after tab close/reload.
/// Native: writes both; reads secure storage first, then prefs fallback.
class AuthTokenStore {
  AuthTokenStore._();

  static const _key = 'sacred_jwt_token';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(
      dbName: 'gevabalAuth',
      publicKey: 'gevabalAuthKey',
    ),
  );

  static Future<void> write(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
    try {
      await _secure.write(key: _key, value: token);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthTokenStore secure write skipped: $e');
      }
    }
  }

  static Future<String?> read() async {
    // Prefer SharedPreferences on web — survives reload reliably.
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      final fromPrefs = prefs.getString(_key);
      if (fromPrefs != null && fromPrefs.isNotEmpty) return fromPrefs;
      try {
        return await _secure.read(key: _key);
      } catch (_) {
        return null;
      }
    }

    try {
      final secure = await _secure.read(key: _key);
      if (secure != null && secure.isNotEmpty) {
        // Keep prefs in sync for fallback.
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, secure);
        return secure;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthTokenStore secure read failed: $e');
      }
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> delete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    try {
      await _secure.delete(key: _key);
    } catch (_) {}
  }
}
