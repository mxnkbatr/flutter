import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_outline_btn.dart';

class SacredButton extends StatelessWidget {
  const SacredButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outline = false,
    this.icon,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outline;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final height = compact ? 44.0 : 52.0;

    if (outline) {
      return SacredOutlineBtn(
        label: label,
        onTap: onTap,
        isLoading: isLoading,
        prefixWidget: icon != null ? Icon(icon, size: 18) : null,
      );
    }

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.goldPrime,
          foregroundColor: AppColors.inkDeep,
          disabledBackgroundColor: AppColors.goldPrime.withOpacity(0.5),
          disabledForegroundColor: AppColors.inkDeep.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _child,
      ),
    );
  }

  Widget get _child => isLoading
      ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.inkDeep,
          ),
        )
      : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppText.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.inkDeep,
              ),
            ),
          ],
        );
}
