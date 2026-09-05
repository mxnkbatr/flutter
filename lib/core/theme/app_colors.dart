import 'package:flutter/material.dart';

/// Warm cream premium palette — soft daylight surfaces + ink + orange accent.
class AppColors {
  AppColors._();

  // ── Primary accent ──
  static const Color orange = Color(0xFFFF8A1F);
  static const Color orangeDeep = Color(0xFFE56F0A);
  static const Color orangeLight = Color(0xFFFFF1E6);
  static const Color orangeSoft = Color(0xFFFFF7F0);
  static const Color orangeMuted = Color(0xFFC97A35);
  static const Color orangePeach = Color(0xFFFFE6D2);

  /// @deprecated Use [orange] — kept for existing references.
  static const Color earthBrown = orange;
  static const Color earthBrownLight = orangeLight;

  // ── Legacy sun/saffron aliases → orange palette ──
  static const Color saffron = orange;
  static const Color saffronDeep = orangeDeep;
  static const Color saffronSoft = orangeSoft;
  static const Color sunYellow = Color(0xFFFFB347);
  static const Color sunOrange = orangeDeep;
  static const Color sunLight = orangeSoft;
  static const Color sunPale = Color(0xFFFFEACC);
  static const Color sunMuted = orangeMuted;

  // ── Warm ink ──
  static const Color inkDeep = Color(0xFF2F1A12);
  static const Color inkMid = Color(0xFF5A3324);
  static const Color inkLight = Color(0xFF7D5240);

  // ── Surfaces (cream stays) ──
  static const Color creamBg = Color(0xFFFFFBF5);
  static const Color creamWash = Color(0xFFFFF6EC);
  static const Color surface = creamBg;
  static const Color surfaceEl = Color(0xFFFFFFFF);
  static const Color surfaceGlass = Color(0xF2FFFFFF);
  static const Color border = Color(0xFFEDE3D6);
  static const Color borderSub = Color(0xFFF3EBE1);

  // ── Text ──
  static const Color textPri = inkDeep;
  static const Color textSec = Color(0xFF8A7B72);
  static const Color textHint = Color(0xFFB5A79D);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xB3FFFFFF);
  static const Color onSun = inkDeep;

  // ── Semantic ──
  static const Color success = Color(0xFF2D9B4E);
  static const Color warning = Color(0xFFE8A000);
  static const Color danger = Color(0xFFE53935);

  static const Color transparent = Color(0x00000000);

  // ── Primary aliases ──
  static const Color goldPrime = orange;
  static const Color goldLight = orangeSoft;
  static const Color goldMuted = orangeMuted;
  static const Color goldDark = orangeDeep;

  static const Color bg = surface;
  static const Color bgElevated = surfaceEl;
  static const Color bgGrouped = surfaceEl;
  static const Color accent = orange;
  static const Color accentLight = orangeSoft;
  static const Color separator = border;
  static const Color label = textPri;
  static const Color secondaryLabel = textSec;
  static const Color info = orange;
  static const Color sunGold = orange;

  static const Color blue = orange;
  static const Color blueDark = orangeDeep;
  static const Color blueDeep = inkMid;
  static const Color blueLight = orangeSoft;
  static const Color blueSoft = orangeSoft;
}
