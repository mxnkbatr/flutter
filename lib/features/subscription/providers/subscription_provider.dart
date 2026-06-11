import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/features/payment/models/qpay_data.dart';

Future<QPayData> createSubscriptionInvoice(
  WidgetRef ref, {
  required String tier,
  required int months,
}) async {
  final res = await ref.read(apiClientProvider).post(
        '/subscription/subscribe',
        data: {'tier': tier, 'months': months},
      );
  return QPayData.fromJson(res.data as Map<String, dynamic>);
}

Future<void> activateSubscription(
  WidgetRef ref, {
  required String tier,
  required String invoiceId,
}) async {
  final res = await ref.read(apiClientProvider).post(
        '/subscription/activate',
        data: {'tier': tier, 'invoiceId': invoiceId},
      );
  final data = res.data as Map<String, dynamic>;
  final expiresRaw = data['expiresAt'] as String? ??
      data['tierExpiresAt'] as String? ??
      data['tier_expires_at'] as String?;
  final expiresAt =
      expiresRaw != null ? DateTime.tryParse(expiresRaw) : null;
  await ref.read(authStateProvider.notifier).updateTier(tier, expiresAt);
  await ref.read(authStateProvider.notifier).refreshProfile();
  ref.invalidate(tierCacheProvider);
}
