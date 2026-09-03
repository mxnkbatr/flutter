import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_text.dart';
import 'package:sacred_app/shared/widgets/sacred_button.dart';

/// Product-grade empty / missing-data illustration used across lists.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.orangeSoft,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.orange.withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, size: 36, color: AppColors.orange),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: AppText.h3.copyWith(fontSize: 18, letterSpacing: -0.3),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppText.bodySmall.copyWith(height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                width: 200,
                child: SacredButton(
                  label: actionLabel!,
                  compact: true,
                  sunShadow: true,
                  onTap: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
