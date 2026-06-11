import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    this.dark = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? AppColors.inkDeep : AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? AppColors.inkLight : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: AppColors.goldPrime, size: 22),
          Text(
            label,
            style: AppText.caption.copyWith(
              color: dark ? AppColors.goldMuted : AppColors.textSec,
            ),
          ),
          Text(
            value,
            style: AppText.h2.copyWith(
              fontSize: 18,
              color: dark ? AppColors.goldPrime : AppColors.textPri,
            ),
          ),
          Text(
            sub,
            style: AppText.caption.copyWith(
              color: dark ? AppColors.goldMuted : AppColors.textSec,
            ),
          ),
        ],
      ),
    );
  }
}
