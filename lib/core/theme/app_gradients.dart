import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  /// Soft premium CTA gradient — bright → warm, no hard neon.
  static const LinearGradient primary = LinearGradient(
    colors: [
      Color(0xFFFFB45C),
      Color(0xFFFF8A1F),
      Color(0xFFE56F0A),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.48, 1.0],
  );

  static const LinearGradient sun = primary;

  static const RadialGradient orangeGlow = RadialGradient(
    colors: [
      Color(0xFFFFC56E),
      Color(0xFFFF8A1F),
      Color(0xFFE56F0A),
    ],
    stops: [0.0, 0.55, 1.0],
    center: Alignment.center,
    radius: 1.0,
  );

  /// Quiet cream atmosphere for cards / sheets.
  static const LinearGradient cardSunrise = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF7F0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient premiumHeader = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFF8F0),
      Color(0xFFFFFBF5),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Soft ambient wash behind home content.
  static const LinearGradient ambientCream = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFBF5),
      Color(0xFFFFF6EC),
      Color(0xFFFFFBF5),
    ],
  );

  static List<BoxShadow> get luxuryShadow => [
        BoxShadow(
          color: const Color(0x14FF8A1F),
          blurRadius: 28,
          spreadRadius: -6,
          offset: const Offset(0, 14),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get luxuryShadowUp => [
        BoxShadow(
          color: const Color(0x18FF8A1F),
          blurRadius: 24,
          spreadRadius: 0,
          offset: const Offset(0, -4),
        ),
      ];

  /// Soft orange-tinted elevation — matches login sheet softness.
  static List<BoxShadow> get softCardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: AppColors.orange.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 4),
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
            color: AppColors.orangeDeep.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      );

  static BoxDecoration cardShadow({double radius = 18}) => BoxDecoration(
        color: AppColors.surfaceEl,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.borderSub, width: 1),
        boxShadow: softCardShadow,
      );
}
