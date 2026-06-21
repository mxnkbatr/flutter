import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';
import 'package:sacred_app/shared/widgets/scale_tap.dart';

class SacredButton extends StatelessWidget {
  const SacredButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outline = false,
    this.icon,
    this.small = false,
    this.compact = false,
    this.sunShadow = false,
    this.prominent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outline;
  final IconData? icon;
  final bool small;
  final bool compact;
  /// Soft amber glow — premium native (bookings CTA).
  final bool sunShadow;
  /// Taller + bolder label for primary empty-state CTAs.
  final bool prominent;

  bool get _isSmall => small || compact;

  @override
  Widget build(BuildContext context) {
    final height = _isSmall ? (prominent ? 48.0 : 44.0) : 54.0;
    final fontSize = _isSmall ? 14.0 : 16.0;
    final fontWeight = prominent ? FontWeight.w800 : FontWeight.w700;
    final radius = _isSmall ? 14.0 : 16.0;

    if (outline) {
      return SizedBox(
        width: double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap?.call();
                },
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.orange, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: _child(fontSize, AppColors.orange, fontWeight),
        ),
      );
    }

    return ScaleTap(
      pressedScale: 0.97,
      onTap: isLoading || onTap == null ? null : onTap,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: onTap != null && !isLoading ? AppGradients.primary : null,
          color: onTap == null || isLoading ? AppColors.border : null,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: onTap != null && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.orangeDeep.withOpacity(0.28),
                    blurRadius: sunShadow ? 12 : 16,
                    offset: Offset(0, sunShadow ? 4 : 6),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: _child(
            fontSize,
            onTap != null && !isLoading ? Colors.white : AppColors.inkDeep,
            fontWeight,
          ),
        ),
      ),
    );
  }

  Widget _child(double fontSize, Color textColor, FontWeight fontWeight) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: textColor,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
