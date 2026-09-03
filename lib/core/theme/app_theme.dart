import 'package:flutter/cupertino.dart';
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
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      fontFamily: AppText.sansFamily,
      scaffoldBackgroundColor: AppColors.creamBg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.orange,
        onPrimary: Colors.white,
        secondary: AppColors.orangeDeep,
        onSecondary: Colors.white,
        surface: AppColors.surfaceEl,
        error: AppColors.danger,
        outline: AppColors.border,
      ),
      textTheme: sans.copyWith(
        displayLarge: serif.displayLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        headlineLarge: serif.headlineLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: sans.titleLarge?.copyWith(
          color: AppColors.textPri,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        bodyLarge: sans.bodyLarge?.copyWith(color: AppColors.textPri, height: 1.5),
        bodyMedium: sans.bodyMedium?.copyWith(color: AppColors.textSec, height: 1.45),
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
          systemNavigationBarColor: AppColors.creamBg,
          systemNavigationBarIconBrightness: Brightness.dark,
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
        shadowColor: Colors.black.withOpacity(0.06),
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
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.orangeDeep,
          textStyle: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceEl,
        hintStyle: AppText.body.copyWith(color: AppColors.textHint),
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
          borderSide: const BorderSide(color: AppColors.orange, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: AppColors.inkDeep,
        contentTextStyle: GoogleFonts.dmSans(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceEl,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: AppText.h3.copyWith(fontSize: 18),
        contentTextStyle: AppText.bodySmall.copyWith(height: 1.5),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceEl,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.surfaceEl,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: false,
        elevation: 0,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.orange,
        linearTrackColor: AppColors.orangeLight,
        circularTrackColor: AppColors.orangeLight,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSub,
        thickness: 0.5,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.inkDeep, size: 22),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
