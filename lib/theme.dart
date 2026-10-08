import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF1E40AF);
  static const secondary = Color(0xFF2563EB);
  static const tertiary = Color(0xFF3B82F6);
  static const neutral = Color(0xFF0F172A);
  static const background = Color(0xFFF5F7FF);
  static const surfaceTint = Color(0xFFEBEEFB);

  /// Gradien biru untuk kartu digital dan elemen sorotan.
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary, tertiary],
  );
}

ThemeData appTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    surface: Colors.white,
    onSurface: AppColors.neutral,
    surfaceContainerHighest: AppColors.surfaceTint,
  );
  final rounded =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.neutral,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.surfaceTint),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: rounded,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(0, 48),
        side: const BorderSide(color: AppColors.surfaceTint),
        shape: rounded,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.surfaceTint),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.surfaceTint,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
