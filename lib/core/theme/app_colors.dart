import 'package:flutter/material.dart';

/// Sacred App — dark luxury + gold palette (see docs/SACRED_APP_DESIGN_SYSTEM.md)
class AppColors {
  AppColors._();

  // ── Dark surfaces ──
  static const Color inkDeep = Color(0xFF1A1208);
  static const Color inkMid = Color(0xFF2C2008);
  static const Color inkLight = Color(0xFF3D3010);

  // ── Sun / gold (iOS explore) ──
  static const Color sunYellow = Color(0xFFFFE566);
  static const Color sunGold = Color(0xFFFFC107);
  static const Color sunOrange = Color(0xFFFF9500);
  static const Color sunLight = Color(0xFFFFF8E7);
  static const Color sunMuted = Color(0xFFB8952E);

  // ── Gold (legacy dark screens) ──
  static const Color goldPrime = Color(0xFFFFC107);
  static const Color goldLight = Color(0xFFFFF8E7);
  static const Color goldMuted = Color(0xFF8B7A4A);
  static const Color goldDark = Color(0xFF8B7A4A);

  // ── Light surfaces ──
  static const Color surface = Color(0xFFFAFAF8);
  static const Color surfaceEl = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E6E0);
  static const Color borderSub = Color(0xFFF0EDE6);

  // ── Text ──
  static const Color textPri = Color(0xFF1A1208);
  static const Color textSec = Color(0xFF888888);
  static const Color textHint = Color(0xFFC0B898);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xB3FFFFFF);
  static const Color transparent = Color(0x00000000);

  // ── Semantic ──
  static const Color success = Color(0xFF2D9B4E);
  static const Color warning = Color(0xFFE8A000);
  static const Color danger = Color(0xFFE53935);

  // Legacy aliases (gradual migration)
  static const Color bg = surface;
  static const Color bgElevated = surfaceEl;
  static const Color bgGrouped = surfaceEl;
  static const Color accent = goldPrime;
  static const Color accentLight = goldLight;
  static const Color separator = border;
  static const Color label = textPri;
  static const Color secondaryLabel = textSec;
  static const Color info = goldPrime;
}
