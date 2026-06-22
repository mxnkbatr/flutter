import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class AdminLogoutButton extends ConsumerWidget {
  const AdminLogoutButton({super.key, this.compact = false});

  final bool compact;

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
    await ref.read(authStateProvider.notifier).logout();
    if (context.mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (compact) {
      return IconButton(
        tooltip: 'Гарах',
        icon: const Icon(Icons.logout_rounded, color: AppColors.inkDeep),
        onPressed: () => _logout(context, ref),
      );
    }
    return TextButton.icon(
      onPressed: () => _logout(context, ref),
      icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.danger),
      label: const Text(
        'Гарах',
        style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
      ),
    );
  }
}
