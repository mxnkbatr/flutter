import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Button / active icon — 135° sunrise → amber
  static const LinearGradient primary = LinearGradient(
    colors: [Color(0xFFF4B234), Color(0xFFD97E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sun = primary;

  /// Card background — dawn light 180°
  static const LinearGradient cardSunrise = LinearGradient(
    colors: [Color(0xFFFFFDF2), Color(0xFFFFF2CC)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Header hero — saffron mandala feel
  static const LinearGradient heroHeader = LinearGradient(
    colors: [Color(0xFFF4B234), Color(0xFFEAA135), Color(0xFFD97E1E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient heroInk = heroHeader;

  static const LinearGradient profileHero = LinearGradient(
    colors: [Color(0xFFF4B234), Color(0xFFE59834), Color(0xFFC97A1A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient inkFromBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0x992B1E10), Color(0x002B1E10)],
  );

  static const LinearGradient inkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x332B1E10), Color(0xCC2B1E10)],
    stops: [0.35, 1.0],
  );

  static const LinearGradient sunAvatar = primary;

  static const LinearGradient monkCardBg = cardSunrise;

  static const LinearGradient sunSoft = cardSunrise;

  static BoxDecoration get pillButton => BoxDecoration(
        gradient: primary,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: AppColors.sunOrange.withOpacity(0.22),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardShadow({double radius = 24}) => BoxDecoration(
        gradient: cardSunrise,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.sunOrange.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );
}
