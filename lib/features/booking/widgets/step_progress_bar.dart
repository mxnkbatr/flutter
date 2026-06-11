import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: (currentStep + 1) / totalSteps,
      backgroundColor: AppColors.inkLight,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.goldPrime),
      minHeight: 3,
    );
  }
}
