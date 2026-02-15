import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF21B6EC);
  static const Color secondary = Color(0xFF6366F1);
  static const Color lightBlue = Color(0xFF5ADFF6);
  static const Color lightGreen = Color(0xFFD1FAE5);
  static const Color lightPurple = Color(0xFFEDE9FE);

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textDark = Color(0xFF161E2B);
  static const Color textGrey = Color(0xFF6B7280);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);

  // Accent used in welcome feature cards
  static const Color accentCyan = Color(0xFF06B6D4);
}

ThemeData appThemeData() {
  final base = ThemeData.light();

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textDark,
      elevation: 0.8,
      iconTheme: IconThemeData(color: AppColors.textDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textTheme: base.textTheme.copyWith(
      bodyLarge: const TextStyle(color: AppColors.textDark),
      bodyMedium: const TextStyle(color: AppColors.textGrey),
      titleLarge: const TextStyle(color: AppColors.textDark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBlue.withAlpha((0.6 * 255).toInt()),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
