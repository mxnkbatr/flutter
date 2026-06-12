import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

  static bool canAccessMonk(String tier, Monk monk) => true;

  static Future<bool> checkMonkAccess(
    BuildContext context,
    WidgetRef ref,
    Monk monk,
  ) async =>
      true;

  static Future<bool> checkBookingLimit(
    BuildContext context,
    WidgetRef ref,
  ) async =>
      true;

  static bool checkVideoCall(BuildContext context, WidgetRef ref) => true;
}
