import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/constants/app_branding.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/gevabal_logo.dart';

/// Cream ambient background — matches home screen aesthetic.
class AuthAmbientBackground extends StatelessWidget {
  const AuthAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orange.withOpacity(0.16),
                    AppColors.orange.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            left: -100,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orangePeach.withOpacity(0.55),
                    AppColors.orangePeach.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.orangeSoft.withOpacity(0.8),
                    AppColors.orangeSoft.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Logo block with soft glow — splash & auth headers.
class AuthBrandHero extends StatelessWidget {
  const AuthBrandHero({
    super.key,
    this.logoHeight = 112,
    this.compact = false,
  });

  final double logoHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GevabalLogo(height: logoHeight, glow: true),
        SizedBox(height: compact ? 14 : 22),
        Text(
          AppBranding.name,
          style: AppText.displaySerif(
            size: compact ? 28 : 34,
            color: AppColors.inkDeep,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppBranding.tagline,
          style: AppText.bodySmall.copyWith(
            color: AppColors.textSec,
            fontSize: compact ? 13 : 14,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}

/// White floating sheet for login/signup forms.
class AuthFormSheet extends StatelessWidget {
  const AuthFormSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
  });

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.borderSub.withOpacity(0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.orange.withOpacity(0.06),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          24,
          title != null ? 28 : 32,
          24,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(title!, style: AppText.displaySerif(size: 24)),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: AppText.bodySmall),
              ],
              const SizedBox(height: 24),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

void setAuthSystemUI() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}
