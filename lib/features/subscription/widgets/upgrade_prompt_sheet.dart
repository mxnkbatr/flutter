import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';

class UpgradePromptSheet extends StatelessWidget {
  const UpgradePromptSheet({
    super.key,
    required this.reason,
    required this.onUpgrade,
  });

  final String reason;
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.inkDeep,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldPrime),
            ),
            child: const Icon(
              Icons.star_rounded,
              color: AppColors.goldPrime,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Premium эрх шаардлагатай',
            style: AppText.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            reason,
            style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onUpgrade();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldPrime,
                foregroundColor: AppColors.inkDeep,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Premium болох'),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Дараа',
              style: AppText.bodySmall.copyWith(color: AppColors.goldMuted),
            ),
          ),
        ],
      ),
    );
  }
}
