import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

/// Circular icon button — iOS-style trailing action (bell, cart, filter…).
class NativeHeaderIconButton extends StatelessWidget {
  const NativeHeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.badgeCount,
    this.iconColor,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final int? badgeCount;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      pressedScale: 0.92,
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.lightImpact();
              onTap!();
            },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: AppColors.surfaceEl,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSub),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.48,
              color: iconColor ?? AppColors.inkDeep,
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -1,
              right: -1,
              child: Container(
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                padding: const EdgeInsets.symmetric(horizontal: 3.5),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.orange.withValues(alpha: 0.35),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount! > 9 ? '9+' : '$badgeCount',
                  style: AppText.caption.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Profile avatar with optional online dot.
class NativeAvatarButton extends StatelessWidget {
  const NativeAvatarButton({
    super.key,
    required this.initial,
    required this.onTap,
    this.size = 44,
    this.showOnlineDot = true,
  });

  final String initial;
  final VoidCallback onTap;
  final double size;
  final bool showOnlineDot;

  @override
  Widget build(BuildContext context) {
    return ScaleTap(
      pressedScale: 0.94,
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: MinimalStyle.avatarBox(radius: size / 2),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: TextStyle(
                color: AppColors.orange.withValues(alpha: 0.8),
                fontSize: size * 0.42,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (showOnlineDot)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: size * 0.27,
                height: size * 0.27,
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.creamBg, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Clean page title — single line, no cheap eyebrow labels.
class NativeLargeTitleHeader extends StatelessWidget {
  const NativeLargeTitleHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.trailing,
    this.leading,
    this.serifTitle = true,
  });

  /// Optional supporting line under the title (service, hint) — not a filler label.
  final String? eyebrow;
  final String title;
  final Widget? trailing;
  final Widget? leading;
  final bool serifTitle;

  static bool _isFillerEyebrow(String? value) {
    if (value == null) return true;
    final v = value.trim().toLowerCase();
    if (v.isEmpty) return true;
    const fillers = {
      'миний',
      'таны',
      'харилцаа',
      'дэлгүүр',
      'буддийн бараа, бэлэг',
    };
    return fillers.contains(v);
  }

  @override
  Widget build(BuildContext context) {
    final support = _isFillerEyebrow(eyebrow) ? null : eyebrow;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppText.pageTitle,
              ),
              if (support != null) ...[
                const SizedBox(height: 4),
                Text(
                  support,
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.textSec,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Compact iOS navigation bar — back + centered title + trailing.
class NativeNavBar extends StatelessWidget {
  const NativeNavBar({
    super.key,
    required this.title,
    this.onBack,
    this.trailing,
    this.leading,
    this.showBorder = true,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;
  final Widget? leading;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final back = leading ??
        (onBack != null
            ? ScaleTap(
                pressedScale: 0.92,
                onTap: () {
                  HapticFeedback.lightImpact();
                  onBack!();
                },
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.inkDeep,
                  ),
                ),
              )
            : null);

    return Container(
      decoration: showBorder
          ? const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderSub),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(width: 48, child: back),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.navTitle,
            ),
          ),
          SizedBox(width: 48, child: trailing),
        ],
      ),
    );
  }
}
