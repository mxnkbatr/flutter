import 'package:flutter/material.dart';
import 'package:sacred_app/shared/widgets/empty_state.dart';

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.cloud_off_outlined,
      title: 'Алдаа гарлаа',
      message: 'Сүлжээгээ шалгаад дахин оролдоно уу',
      actionLabel: 'Дахин оролдох',
      onAction: onRetry,
    );
  }
}
