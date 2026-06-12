import 'package:flutter/material.dart';

/// Premium native sun / saffron palette — warm, not neon.
class AppColors {
  AppColors._();

  // ── Variant A: Saffron Glow (spiritual depth) ──
  static const Color saffron = Color(0xFFEAA135);
  static const Color saffronDeep = Color(0xFFE59834);
  static const Color saffronSoft = Color(0xFFFFF9E6);

  // ── Variant B: Morning Sunrise (UI primary) ──
  static const Color sunYellow = Color(0xFFF4B234);
  static const Color sunOrange = Color(0xFFD97E1E);
  static const Color sunLight = Color(0xFFFFFDF2);
  static const Color sunPale = Color(0xFFFFF2CC);
  static const Color sunMuted = Color(0xFFB8894A);

  // ── Warm ink (text on sun surfaces — not pure black) ──
  static const Color inkDeep = Color(0xFF2B1E10);
  static const Color inkMid = Color(0xFF3D2A14);
  static const Color inkLight = Color(0xFF5C4A38);

  // ── Surfaces ──
  static const Color surface = Color(0xFFFAF8F5);
  static const Color surfaceEl = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEDE8DF);
  static const Color borderSub = Color(0xFFF5F0E8);

  // ── Text ──
  static const Color textPri = inkDeep;
  static const Color textSec = Color(0xFF7A6B58);
  static const Color textHint = Color(0xFFB5A898);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xB3FFFFFF);
  static const Color onSun = inkDeep;

  // ── Semantic ──
  static const Color success = Color(0xFF2D9B4E);
  static const Color warning = Color(0xFFE8A000);
  static const Color danger = Color(0xFFE53935);

  static const Color transparent = Color(0x00000000);

  // ── Primary aliases ──
  static const Color goldPrime = sunYellow;
  static const Color goldLight = sunLight;
  static const Color goldMuted = sunMuted;
  static const Color goldDark = sunOrange;

  static const Color bg = surface;
  static const Color bgElevated = surfaceEl;
  static const Color bgGrouped = surfaceEl;
  static const Color accent = sunYellow;
  static const Color accentLight = saffronSoft;
  static const Color separator = border;
  static const Color label = textPri;
  static const Color secondaryLabel = textSec;
  static const Color info = sunYellow;
  static const Color sunGold = sunYellow;

  // Backward compat (blue → sun)
  static const Color blue = sunYellow;
  static const Color blueDark = sunOrange;
  static const Color blueDeep = inkMid;
  static const Color blueLight = saffronSoft;
  static const Color blueSoft = sunLight;
}
