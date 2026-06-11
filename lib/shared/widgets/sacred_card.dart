import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SacredCard extends StatelessWidget {
  const SacredCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.inkDeep = false,
    this.margin,
  });

  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool inkDeep;
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: inkDeep ? AppColors.inkMid : AppColors.surfaceEl,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: inkDeep ? AppColors.inkLight : AppColors.border,
            width: 0.5,
          ),
        ),
        child: child,
      ),
    );
  }
}
