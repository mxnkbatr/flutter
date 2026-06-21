import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Vibrant orange chip / button gradient (mockup).
  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFFFFB347),
      Color(0xFFFF8C2A),
      Color(0xFFE8740F),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient sun = primary;

  static const RadialGradient orangeGlow = RadialGradient(
    colors: [
      Color(0xFFFFC56E),
      Color(0xFFFF8C2A),
      Color(0xFFE8740F),
    ],
    stops: [0.0, 0.55, 1.0],
    center: Alignment.center,
    radius: 1.0,
  );

  static const LinearGradient cardSunrise = LinearGradient(
    colors: [Color(0xFFFFFBF5), Color(0xFFFFF0E5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF6EE),
      Color(0xFFFFFBF5),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.6, 1.0],
  );

  static List<BoxShadow> get luxuryShadow => [
        BoxShadow(
          color: AppColors.orange.withOpacity(0.06),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get luxuryShadowUp => [
        BoxShadow(
          color: AppColors.orange.withOpacity(0.08),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, -4),
        ),
      ];

  static const LinearGradient heroHeader = primary;
  static const LinearGradient heroInk = primary;

  static const LinearGradient profileHero = primary;

  static const LinearGradient inkFromBottom = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [Color(0x993E1F14), Color(0x003E1F14)],
  );

  static const LinearGradient inkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x333E1F14), Color(0xCC3E1F14)],
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
            color: AppColors.orangeDeep.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration cardShadow({double radius = 16}) => BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSub, width: 1),
        boxShadow: luxuryShadow,
      );
}
