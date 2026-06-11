import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/ios_grouped_section.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final tier = ref.watch(userTierProvider);

    return IosLargeTitleScaffold(
      title: 'Профайл',
      body: Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.accentLight,
                child: Text(
                  (auth?.userName?.isNotEmpty ?? false)
                      ? auth!.userName![0].toUpperCase()
                      : '?',
                  style: AppText.h1.copyWith(color: AppColors.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(auth?.userName ?? '', style: AppText.h2),
            Text(
              '${tierLabel(tier)} · ${auth?.role ?? 'client'}',
              style: AppText.bodySmall,
            ),
            const SizedBox(height: 24),
            IosGroupedSection(
              title: 'Тохиргоо',
              children: [
                ListTile(
                  leading: const Icon(Icons.star_outline_rounded, color: AppColors.accent),
                  title: const Text('Premium багц'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSec),
                  onTap: () => context.push('/subscription'),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: AppColors.accent),
                  title: const Text('Мэдэгдэл'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSec),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            IosGroupedSection(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
                  title: Text('Гарах', style: AppText.body.copyWith(color: AppColors.danger)),
                  onTap: () => ref.read(authStateProvider.notifier).logout(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
