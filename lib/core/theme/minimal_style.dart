import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';
import 'package:sacred_app/core/theme/app_gradients.dart';

/// Shared minimal surfaces — cream canvas + floating white cards.
class MinimalStyle {
  MinimalStyle._();

  /// Login-soft list cards (16–20).
  static const double cardRadius = 18;
  static const double cardRadiusLg = 20;

  static BoxDecoration card({double radius = cardRadius}) => BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSub, width: 1),
        boxShadow: AppGradients.softCardShadow,
      );

  static BoxDecoration glassCard({double radius = cardRadius}) => BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSub.withValues(alpha: 0.9)),
        boxShadow: AppGradients.softCardShadow,
      );

  static BoxDecoration avatarBox({double radius = 14}) => BoxDecoration(
        color: AppColors.orangePeach,
        borderRadius: BorderRadius.circular(radius),
      );
}
