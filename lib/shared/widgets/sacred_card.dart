import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/minimal_style.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class SacredCard extends StatelessWidget {
  const SacredCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.inkDeep = false,
    this.margin,
    this.radius,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool inkDeep;
  final EdgeInsets? margin;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: inkDeep
          ? BoxDecoration(
              color: AppColors.inkMid,
              borderRadius: BorderRadius.circular(radius ?? MinimalStyle.cardRadius),
            )
          : MinimalStyle.card(radius: radius ?? MinimalStyle.cardRadius),
      child: child,
    );

    if (onTap == null) return card;

    return ScaleTap(
      pressedScale: 0.985,
      onTap: onTap,
      child: card,
    );
  }
}
