import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/features/profile/widgets/profile_settings_group.dart';
import 'package:sacred_app/shared/widgets/premium_layered_scaffold.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final tier = ref.watch(userTierProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;
    final initial =
        (auth?.userName?.isNotEmpty ?? false) ? auth!.userName![0].toUpperCase() : '?';

    return PremiumLayeredScaffold(
      subtitle: 'Миний',
      title: 'Профайл',
      expandBody: true,
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(0, 8, 0, bottomPad),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
              decoration: MinimalStyle.card(radius: MinimalStyle.cardRadiusLg),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E8E8),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.borderSub, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: AppColors.inkDeep,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    auth?.userName ?? 'Зочин',
                    style: AppText.h2.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.orange.withOpacity(0.22),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          tierLabel(tier),
                          style: AppText.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ProfileSettingsGroup(
            title: 'Тохиргоо',
            children: [
              ProfileSettingsTile(
                icon: Icons.star_rounded,
                iconBackground: AppColors.orangeLight,
                iconColor: AppColors.orange,
                title: 'Premium багц',
                onTap: () => context.push('/subscription'),
              ),
              ProfileSettingsTile(
                icon: Icons.notifications_outlined,
                iconBackground: const Color(0xFFFFECEC),
                iconColor: const Color(0xFFE85D5D),
                title: 'Мэдэгдэл',
                onTap: () => context.push('/notifications'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ProfileSettingsGroup(
            children: [
              ProfileSettingsTile(
                icon: Icons.logout_rounded,
                iconBackground: const Color(0xFFFFEBEB),
                iconColor: AppColors.danger,
                title: 'Гарах',
                titleColor: AppColors.danger,
                titleWeight: FontWeight.w500,
                showChevron: false,
                onTap: () => ref.read(authStateProvider.notifier).logout(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
