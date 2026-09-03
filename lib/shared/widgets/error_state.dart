import 'package:flutter/material.dart';
import 'package:sacred_app/core/utils/error_messages.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.error,
    this.fallback,
    this.onRetry,
    this.icon = Icons.cloud_off_outlined,
  });

  final Object error;
  final String? fallback;
  final VoidCallback? onRetry;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: icon,
      title: 'Ачаалахад алдаа гарлаа',
      message: formatUserError(error, fallback: fallback ?? 'Дахин оролдоно уу.'),
      actionLabel: onRetry != null ? 'Дахин оролдох' : null,
      onAction: onRetry,
    );
  }
}
