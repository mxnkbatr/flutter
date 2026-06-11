import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppColors.goldMuted,
          ),
          const SizedBox(height: 12),
          Text('Алдаа гарлаа', style: AppText.h3),
          const SizedBox(height: 8),
          Text(
            'Дахин оролдоно уу',
            style: AppText.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          SacredButton(
            label: 'Дахин оролдох',
            compact: true,
            onTap: onRetry,
          ),
        ],
      ),
    );
  }
}
