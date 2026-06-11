import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class SacredOutlineBtn extends StatelessWidget {
  const SacredOutlineBtn({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.prefixWidget,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final Widget? prefixWidget;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading
            ? null
            : () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surfaceEl,
          foregroundColor: AppColors.textPri,
          side: const BorderSide(color: AppColors.border, width: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.goldPrime,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (prefixWidget != null) ...[
                    prefixWidget!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: AppText.body.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
