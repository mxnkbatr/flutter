import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/features/home/models/monk.dart';
import 'package:sacred_app/features/subscription/widgets/upgrade_prompt_sheet.dart';
import 'package:sacred_app/shared/widgets/app_modal_sheet.dart';

class TierGating {
  TierGating._();

  static void showUpgrade(
    BuildContext context, {
    required String reason,
    VoidCallback? onUpgrade,
  }) {
    showAppModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => UpgradePromptSheet(
        reason: reason,
        onUpgrade: onUpgrade ?? () => context.go('/subscription'),
      ),
    );
  }

  static bool canAccessMonk(String tier, Monk monk) {
    if (!monk.isSpecial) return true;
    return tier == 'premium' || tier == 'vip';
  }

  static Future<bool> checkMonkAccess(
    BuildContext context,
    WidgetRef ref,
    Monk monk,
  ) async {
    final tier = ref.read(userTierProvider);
    if (canAccessMonk(tier, monk)) return true;
    showUpgrade(
      context,
      reason: 'Энэ лам зөвхөн Premium гишүүдэд нээлттэй',
    );
    return false;
  }

  static Future<bool> checkBookingLimit(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final tier = ref.read(userTierProvider);
    if (tier != 'free') return true;

    final count = await ref.read(userBookingCountProvider.future);
    if (count >= 3) {
      showUpgrade(
        context,
        reason: 'Үнэгүй хэрэглэгч сард 3 захиалга хийх боломжтой',
      );
      return false;
    }
    return true;
  }

  static bool checkVideoCall(BuildContext context, WidgetRef ref) {
    final tier = ref.read(userTierProvider);
    if (tier != 'free') return true;
    showUpgrade(
      context,
      reason: 'Видео дуудлага Premium гишүүдэд нээлттэй',
    );
    return false;
  }
}
