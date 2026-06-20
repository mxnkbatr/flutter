import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sacred_app/core/auth/auth_provider.dart';
import 'package:sacred_app/core/auth/tier_provider.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/features/profile/widgets/profile_page_scaffold.dart';
import 'package:sacred_app/features/profile/widgets/profile_settings_group.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).valueOrNull;
    final tier = ref.watch(userTierProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom + 80;
    final initial =
        (auth?.userName?.isNotEmpty ?? false) ? auth!.userName![0].toUpperCase() : '?';

    return ProfilePageScaffold(
      header: _ProfileHero(
        initial: initial,
        userName: auth?.userName ?? '',
        tierLabel: tierLabel(tier),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(0, 24, 0, bottomPad),
        children: [
          ProfileSettingsGroup(
            title: 'Тохиргоо',
            children: [
              ProfileSettingsTile(
                icon: Icons.star_rounded,
                iconBackground: const Color(0xFFFFF4E0),
                iconColor: AppColors.saffronDeep,
                title: 'Premium багц',
                onTap: () => context.push('/subscription'),
              ),
              ProfileSettingsTile(
                icon: Icons.notifications_outlined,
                iconBackground: const Color(0xFFFFECEC),
                iconColor: const Color(0xFFE85D5D),
                title: 'Мэдэгдэл',
                onTap: () => context.push('/profile/notifications'),
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

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.initial,
    required this.userName,
    required this.tierLabel,
  });

  final String initial;
  final String userName;
  final String tierLabel;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(top: top + 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppGradients.sunAvatar,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.65),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            userName,
            style: AppText.h2.copyWith(
              color: AppColors.onDark,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  size: 14,
                  color: Colors.white.withOpacity(0.95),
                ),
                const SizedBox(width: 6),
                Text(
                  tierLabel,
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
    );
  }
}
