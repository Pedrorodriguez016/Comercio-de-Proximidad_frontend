import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF2D4739);
  static const Color secondary = Color(0xFFC17E53);
  static const Color tertiary = Color(0xFFE5E1D8);
  static const Color neutral = Color(0xFF777775);
  static const Color background = Color(0xFFF9F8F6); // Very light version of tertiary
  static const Color surface = Colors.white;
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF1A1A1A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        background: AppColors.background,
        onPrimary: AppColors.onPrimary,
        onSecondary: AppColors.onSecondary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.notoSerif(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 16,
          color: AppColors.onBackground,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 14,
          color: AppColors.neutral,
        ),
        labelLarge: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.primary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: GoogleFonts.manrope(fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.tertiary.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: GoogleFonts.manrope(color: AppColors.neutral),
      ),
    );
  }
}
