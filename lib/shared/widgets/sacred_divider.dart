import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

class SacredDivider extends StatelessWidget {
  const SacredDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.borderSub,
      thickness: 0.5,
      height: 0.5,
    );
  }
}
