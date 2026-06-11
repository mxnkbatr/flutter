import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/subscription/widgets/upgrade_prompt_sheet.dart';

class TierGating {
  TierGating._();

  static void showUpgrade(
    BuildContext context, {
    required String reason,
    VoidCallback? onUpgrade,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UpgradePromptSheet(
        reason: reason,
        onUpgrade: onUpgrade ??
            () {
              Navigator.of(context).pop();
              context.go('/subscription');
            },
      ),
    );
  }

  static bool canAccessMonk(String tier, Monk monk) {
    if (monk.isVip) return tier == 'vip';
    if (monk.isSpecial) return tier.canAccessFeaturedMonks;
    return true;
  }

  static Future<bool> checkMonkAccess(
    BuildContext context,
    WidgetRef ref,
    Monk monk,
  ) async {
    final tier = ref.read(userTierProvider);
    if (canAccessMonk(tier, monk)) return true;

    final reason = monk.isVip
        ? 'VIP лам нар зөвхөн VIP эрхтэй'
        : 'Онцлох лам нар Premium эрхтэй';
    showUpgrade(context, reason: reason);
    return false;
  }

  static Future<bool> checkBookingLimit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final tier = ref.read(userTierProvider);
    if (tier.canBookUnlimited) return true;

    final count = await ref.read(userBookingCountProvider.future);
    if (count < 3) return true;

    if (context.mounted) {
      showUpgrade(context, reason: '3 захиалгын хязгаарт хүрлээ');
    }
    return false;
  }

  static bool checkVideoCall(BuildContext context, WidgetRef ref) {
    final tier = ref.read(userTierProvider);
    if (tier.canVideoCall) return true;
    showUpgrade(context, reason: 'Видео дуудлага Premium эрхтэй');
    return false;
  }
}
