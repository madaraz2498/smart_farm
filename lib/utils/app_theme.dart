import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const primaryLight = Color(0xFFE8F5E9);
  static const background = Color(0xFFFAFBF7);
  static const surface = Colors.white;
  static const textDark = Color(0xFF1F2937);
  static const textMuted = Color(0xFF6B7280);
  static const border = Color(0x14000000); // ~8% black
  static const error = Color(0xFFDC2626);
  static const notifRed = Color(0xFFFB2C36);
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: AppColors.textDark),
          titleTextStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 1,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
}
