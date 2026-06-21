import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text.dart';

class AppTheme {
  static ThemeData get light {
    final sans = GoogleFonts.dmSansTextTheme();
    final serif = GoogleFonts.playfairDisplayTextTheme();

    return ThemeData(
      useMaterial3: true,
      fontFamily: AppText.sansFamily,
      scaffoldBackgroundColor: AppColors.creamBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.orange,
        onPrimary: Colors.white,
        secondary: AppColors.orangeDeep,
        onSecondary: Colors.white,
        surface: AppColors.surfaceEl,
        error: AppColors.danger,
      ),
      textTheme: sans.copyWith(
        displayLarge: serif.displayLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
        ),
        headlineLarge: serif.headlineLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: sans.titleLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: sans.bodyLarge?.copyWith(color: AppColors.textPri),
        bodyMedium: sans.bodyMedium?.copyWith(color: AppColors.textSec),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.creamBg,
        foregroundColor: AppColors.textPri,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppText.navTitle,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceEl,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceEl,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSub, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceEl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSub, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderSub, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.orange, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSub,
        thickness: 0.5,
      ),
    );
  }
}
