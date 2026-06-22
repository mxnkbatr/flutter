import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sacred_app/core/api/api_client.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/admin/models/admin_user.dart';
import 'package:sacred_app/features/admin/providers/admin_providers.dart';
import 'package:sacred_app/shared/widgets/sacred_card.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Хэрэглэгчид')),
      body: usersAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldPrime),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(formatUserError(e)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(adminUsersProvider),
                child: const Text('Дахин оролдох'),
              ),
            ],
          ),
        ),
        data: (users) => RefreshIndicator(
          color: AppColors.goldPrime,
          onRefresh: () => ref.refresh(adminUsersProvider.future),
          child: users.isEmpty
              ? const Center(child: Text('Хэрэглэгч байхгүй'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (_, i) => _UserCard(user: users[i]),
                ),
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard({required this.user});
  final AdminUser user;

  Future<void> _toggleBlock(BuildContext context, WidgetRef ref) async {
    final action = user.isActive ? 'block' : 'unblock';
    final label = user.isActive ? 'хаах' : 'нээх';
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Хэрэглэгч $label уу?'),
        content: Text(user.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: user.isActive ? AppColors.danger : AppColors.success,
            ),
            child: Text(label[0].toUpperCase() + label.substring(1)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(apiClientProvider).post('/admin/users/${user.id}/$action');
      ref.invalidate(adminUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${user.name} — ${user.isActive ? "хаагдлаа" : "нээгдлээ"}',
            ),
            backgroundColor: user.isActive ? AppColors.warning : AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    if (user.role == 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Админ бүртгэл устгах боломжгүй')),
      );
      return;
    }
    if (user.role == 'monk') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ламын бүртгэлийг "Лам" хэсгээс устгана уу')),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Хэрэглэгч устгах уу?'),
        content: Text('${user.name} (${user.email}) бүртгэл бүрмөсөн устгагдана.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Болих'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    try {
      await deleteUserWithForceIfNeeded(
        ref,
        user.id,
        confirmForce: (msg) => showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Идэвхтэй захиалга'),
            content: Text('$msg\n\nЗахиалгуудыг цуцлаад устгах уу?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Болих'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Цуцлаад устгах'),
              ),
            ],
          ),
        ),
      );
      ref.invalidate(adminUsersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} устгагдлаа'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(formatUserError(e)),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SacredCard(
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.goldLight,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: AppText.body.copyWith(
                  color: AppColors.saffronDeep,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                  Text(user.email, style: AppText.bodySmall),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _Badge(
                        label: user.isActive ? 'Идэвхтэй' : 'Хаагдсан',
                        color: user.isActive ? AppColors.success : AppColors.danger,
                      ),
                      const SizedBox(width: 6),
                      _Badge(label: user.role, color: AppColors.textSec),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: user.isActive ? 'Хаах' : 'Нээх',
              icon: Icon(
                user.isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_outline_rounded,
                color: user.isActive ? AppColors.danger : AppColors.success,
              ),
              onPressed: () => _toggleBlock(context, ref),
            ),
            if (user.role == 'client')
              IconButton(
                tooltip: 'Устгах',
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                onPressed: () => _delete(context, ref),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppText.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
