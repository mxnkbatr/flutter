import 'package:shared_preferences/shared_preferences.dart';

class TierCacheData {
  const TierCacheData({required this.tier, this.expiresAt});

  final String tier;
  final DateTime? expiresAt;
}

class TierCache {
  TierCache._();

  static const _tierKey = 'sacred_user_tier';
  static const _expiresKey = 'sacred_tier_expires';

  static Future<void> save(String tier, DateTime? expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tierKey, tier);
    if (expiresAt != null) {
      await prefs.setString(_expiresKey, expiresAt.toIso8601String());
    } else {
      await prefs.remove(_expiresKey);
    }
  }

  static Future<TierCacheData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final tier = prefs.getString(_tierKey);
    if (tier == null) return null;
    final expiresRaw = prefs.getString(_expiresKey);
    return TierCacheData(
      tier: tier,
      expiresAt: expiresRaw != null ? DateTime.tryParse(expiresRaw) : null,
    );
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tierKey);
    await prefs.remove(_expiresKey);
  }
}
