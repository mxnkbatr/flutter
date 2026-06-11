import 'package:flutter/material.dart';
import 'package:sacred_app/core/theme/app_colors.dart';

/// Гэрэлт шар / нарны gradient — iOS explore загвар
class AppGradients {
  AppGradients._();

  static const LinearGradient sun = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.sunYellow,
      AppColors.sunGold,
      AppColors.sunOrange,
    ],
  );

  static const LinearGradient sunHorizontal = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.sunYellow,
      AppColors.sunGold,
      AppColors.sunOrange,
    ],
  );

  static const LinearGradient sunSoft = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFDF5),
      Color(0xFFFFF4D6),
    ],
  );

  static BoxDecoration get pillButton => BoxDecoration(
        gradient: sun,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.sunGold.withOpacity( 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardShadow({double radius = 20}) => BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
