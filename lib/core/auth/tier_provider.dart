import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_cache.dart';

final tierCacheProvider = FutureProvider<TierCacheData?>((ref) async {
  return TierCache.load();
});

/// Effective tier — auth state + offline cache, expired tiers fall back to free.
final userTierProvider = Provider<String>((ref) {
  final auth = ref.watch(authStateProvider).valueOrNull;
  final cached = ref.watch(tierCacheProvider).valueOrNull;

  final tier = auth?.tier ?? cached?.tier ?? 'free';
  final expiresAt = auth?.tierExpiresAt ?? cached?.expiresAt;

  if (expiresAt != null && DateTime.now().isAfter(expiresAt)) {
    return 'free';
  }
  return tier;
});

final userBookingCountProvider = FutureProvider<int>((ref) async {
  final month = DateFormat('yyyy-MM').format(DateTime.now());
  try {
    final res = await ref.read(apiClientProvider).get(
          '/bookings',
          queryParameters: {'month': month},
        );
    final list = res.data is List
        ? res.data as List
        : (res.data as Map<String, dynamic>)['bookings'] as List? ?? [];
    return list.length;
  } catch (_) {
    return 0;
  }
});

extension TierExtension on String {
  bool get canVideoCall => this != 'free';
  bool get canAccessFeaturedMonks => this != 'free';
  bool get canGroupCall => this == 'vip';
  bool get canBookUnlimited => this != 'free';

  int get discountPercent => switch (this) {
        'premium' => 10,
        'vip' => 20,
        _ => 0,
      };
}

String tierLabel(String tier) => switch (tier) {
      'premium' => 'Premium',
      'vip' => 'VIP',
      _ => 'Үнэгүй',
    };
