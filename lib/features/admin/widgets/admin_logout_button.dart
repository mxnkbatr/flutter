import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/auth/auth_actions.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class AdminLogoutButton extends ConsumerWidget {
  const AdminLogoutButton({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Гарах уу?'),
        content: const Text('Админ самбараас гарна.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Үгүй'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Гарах'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    HapticFeedback.lightImpact();
    await performLogout(ref, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScaleTap(
      pressedScale: 0.96,
      onTap: () => _logout(context, ref),
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.danger.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 17,
              color: AppColors.danger.withOpacity(0.92),
            ),
            const SizedBox(width: 6),
            Text(
              'Гарах',
              style: AppText.caption.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
