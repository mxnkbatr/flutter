import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography — same faces as login ([GoogleFonts.manrope] + Playfair brand).
class AppText {
  AppText._();

  static String get sansFamily =>
      GoogleFonts.manrope().fontFamily ?? 'Manrope';

  /// Latin brand wordmark only (Playfair has limited Cyrillic).
  static String get serifFamily =>
      GoogleFonts.playfairDisplay().fontFamily ?? 'Playfair Display';

  static TextStyle _sans({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textPri,
    double? letterSpacing,
    double? height,
  }) =>
      GoogleFonts.manrope(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle get largeTitle => _sans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.15,
      );

  /// Login sheet titles — Manrope (Cyrillic-ready), not Playfair.
  static TextStyle displaySerif({
    double size = 28,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPri,
  }) =>
      _sans(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: -0.8,
        height: 1.15,
      );

  static TextStyle get h1 => _sans(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      );

  static TextStyle get h2 => _sans(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.25,
      );

  static TextStyle get h3 => _sans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.3,
      );

  static TextStyle get body => _sans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
        letterSpacing: -0.1,
      );

  static TextStyle get bodySmall => _sans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSec,
        height: 1.4,
        letterSpacing: -0.05,
      );

  static TextStyle get caption => _sans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSec,
        letterSpacing: -0.05,
      );

  static TextStyle get goldLabel => _sans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.goldPrime,
        letterSpacing: 0.2,
      );

  static TextStyle get price => _sans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      );

  static TextStyle get brandTitle => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.inkDeep,
        letterSpacing: -0.3,
        height: 1,
      );

  static TextStyle get navTitle => _sans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      );

  static TextStyle get pageTitle => _sans(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.inkDeep,
        letterSpacing: -0.9,
        height: 1.1,
      );

  static TextStyle get chipInactive => _sans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
      );

  static TextStyle get chipActive => _sans(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.1,
      );
}
