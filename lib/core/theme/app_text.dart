import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static const String sansFamily = 'DM Sans';
  static const String serifFamily = 'Playfair Display';

  /// Large display — serif (Мэдэгдэл, tab titles).
  static const TextStyle largeTitle = TextStyle(
    fontFamily: serifFamily,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPri,
    letterSpacing: -0.3,
    height: 1.08,
  );

  static TextStyle displaySerif({
    double size = 34,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPri,
  }) =>
      largeTitle.copyWith(
        fontSize: size,
        fontWeight: weight,
        color: color,
      );

  static const TextStyle h1 = TextStyle(
    fontFamily: sansFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPri,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: sansFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPri,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPri,
  );

  static const TextStyle body = TextStyle(
    fontFamily: sansFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPri,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSec,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textSec,
    letterSpacing: 0.2,
  );

  static const TextStyle goldLabel = TextStyle(
    fontFamily: sansFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrime,
    letterSpacing: 0.5,
  );

  static const TextStyle price = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPri,
  );

  static const TextStyle brandTitle = TextStyle(
    fontFamily: serifFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.goldPrime,
    letterSpacing: 1.5,
  );

  static const TextStyle navTitle = TextStyle(
    fontFamily: sansFamily,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: AppColors.textPri,
  );

  static const TextStyle chipInactive = TextStyle(
    fontFamily: sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPri,
  );

  static const TextStyle chipActive = TextStyle(
    fontFamily: sansFamily,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
