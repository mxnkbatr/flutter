import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/core/utils/error_messages.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    this.fallback,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
  });

  final Object error;
  final String? fallback;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: AppColors.danger),
            const SizedBox(height: 12),
            Text(
              formatUserError(error, fallback: fallback ?? 'Алдаа гарлаа.'),
              style: AppText.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: onRetry,
                child: const Text('Дахин оролдох'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
