import 'package:flutter/material.dart';

/// Warm premium palette — matches mockup (#FFFBF5 cream + maroon ink + orange).
class AppColors {
  AppColors._();

  // ── Primary accent — vibrant orange gradient endpoints ──
  static const Color orange = Color(0xFFFF8C2A);
  static const Color orangeDeep = Color(0xFFE8740F);
  static const Color orangeLight = Color(0xFFFFF0E5);
  static const Color orangeSoft = Color(0xFFFFF8F2);
  static const Color orangeMuted = Color(0xFFD4823A);
  static const Color orangePeach = Color(0xFFFFE8D6);

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

  // ── Warm ink (maroon-brown headings) ──
  static const Color inkDeep = Color(0xFF3E1F14);
  static const Color inkMid = Color(0xFF5C3020);
  static const Color inkLight = Color(0xFF7A4A38);

  // ── Surfaces ──
  static const Color creamBg = Color(0xFFFFFBF5);
  static const Color surface = creamBg;
  static const Color surfaceEl = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFF0E6DA);
  static const Color borderSub = Color(0xFFF5EDE4);

  // ── Text ──
  static const Color textPri = inkDeep;
  static const Color textSec = Color(0xFF8E8E93);
  static const Color textHint = Color(0xFFAEAEB2);
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
