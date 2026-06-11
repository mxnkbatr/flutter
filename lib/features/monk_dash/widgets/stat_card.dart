import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.dark = false,
    this.accent = false,
    this.danger = false,
  });

  final String label;
  final String value;
  final String sub;
  final bool dark;
  final bool accent;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppColors.inkDeep : AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark
              ? AppColors.goldPrime.withOpacity(0.3)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppText.caption.copyWith(
              color: dark ? AppColors.goldMuted : AppColors.textSec,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.h2.copyWith(
              color: dark || accent
                  ? AppColors.goldPrime
                  : AppColors.textPri,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sub,
            style: AppText.caption.copyWith(
              color: danger
                  ? AppColors.danger
                  : dark
                      ? AppColors.goldMuted.withOpacity(0.7)
                      : AppColors.textSec,
            ),
          ),
        ],
      ),
    );
  }
}
