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
              border: Border.all(color: AppColors.borderSub, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: size * 0.48,
              color: iconColor ?? AppColors.orange,
            ),
          ),
          if (badgeCount != null && badgeCount! > 0)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeCount! > 9 ? '9+' : '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1,
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
                color: AppColors.orange.withOpacity(0.8),
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

/// iOS large-title block: small eyebrow + bold title + optional trailing.
class NativeLargeTitleHeader extends StatelessWidget {
  const NativeLargeTitleHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.trailing,
    this.leading,
    this.serifTitle = true,
  });

  final String? eyebrow;
  final String title;
  final Widget? trailing;
  final Widget? leading;
  final bool serifTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (eyebrow != null && eyebrow!.isNotEmpty)
                Text(
                  eyebrow!,
                  style: AppText.bodySmall.copyWith(
                    color: AppColors.textSec,
                    fontSize: 14,
                    height: 1.2,
                  ),
                ),
              Text(
                title,
                style: serifTitle
                    ? AppText.largeTitle
                    : AppText.h1.copyWith(fontSize: 30),
              ),
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
            : const SizedBox(width: 40));

    return Container(
      decoration: showBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderSub.withOpacity(0.8),
                ),
              ),
            )
          : null,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            back,
            Expanded(
              child: Text(
                title,
                style: AppText.navTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 40,
              child: trailing != null
                  ? Align(alignment: Alignment.centerRight, child: trailing)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
