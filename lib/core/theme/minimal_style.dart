import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

/// Shared minimal surfaces — warm cream + white floating cards.
class MinimalStyle {
  MinimalStyle._();

  static const double cardRadius = 16;
  static const double cardRadiusLg = 20;

  static BoxDecoration card({double radius = cardRadius}) => BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSub, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration avatarBox({double radius = 14}) => BoxDecoration(
        color: AppColors.orangePeach,
        borderRadius: BorderRadius.circular(radius),
      );
}
