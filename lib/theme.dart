import 'package:flutter/material.dart';

const appName = 'SmartLink Business Card';

/// Token warna design system "SmartLink" dari proyek Stitch.
class AppColors {
  /// Biru brand untuk aksen, judul kartu, dan navigasi aktif.
  static const primary = Color(0xFF1E40AF);

  /// Biru aksi untuk tombol utama.
  static const secondary = Color(0xFF2563EB);
  static const tertiary = Color(0xFF3B82F6);
  static const primaryContainer = Color(0xFFEFF6FF);
  static const primaryBorder = Color(0xFFBFDBFE);
  static const primarySoftBorder = Color(0xFFDBEAFE);

  static const canvas = Color(0xFFF8FAFC);
  static const tonal = Color(0xFFF1F5F9);
  static const outline = Color(0xFFE2E8F0);
  static const outlineSoft = Color(0xFFF1F5F9);

  static const textPrimary = Color(0xFF0F172A);
  static const textBody = Color(0xFF334155);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  static const success = Color(0xFF059669);
  static const successStrong = Color(0xFF047857);
  static const successDot = Color(0xFF10B981);
  static const successContainer = Color(0xFFECFDF5);
  static const successBorder = Color(0xFFA7F3D0);
  static const purple = Color(0xFF7E22CE);
  static const purpleContainer = Color(0xFFFAF5FF);
  static const purpleBorder = Color(0xFFF3E8FF);
  static const indigo = Color(0xFF4F46E5);
  static const indigoContainer = Color(0xFFEEF2FF);
  static const indigoBorder = Color(0xFFE0E7FF);
  static const warning = Color(0xFFD97706);
  static const warningContainer = Color(0xFFFFFBEB);
  static const error = Color(0xFFDC2626);
  static const errorContainer = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFEE2E2);

  // Nama lama tetap tersedia untuk layar admin.
  static const neutral = textPrimary;
  static const background = canvas;
  static const surfaceTint = outline;

  /// Gradien kartu digital di Beranda.
  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF1D4ED8), secondary],
  );

  /// Gradien kartu pratinjau di editor.
  static const previewGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), secondary, Color(0xFF1D4ED8)],
  );

  /// Gradien sampul profil publik.
  static const bannerGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [Color(0xFF1D4ED8), indigo, Color(0xFF38BDF8)],
  );
}

/// Bayangan bertingkat sesuai "Elevation & Depth" SmartLink.
class AppShadows {
  static const level1 = [
    BoxShadow(
      color: Color(0x0D0F172A),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x080F172A),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
  static const level2 = [
    BoxShadow(
      color: Color(0x0F1E40AF),
      blurRadius: 6,
      spreadRadius: -1,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 4,
      spreadRadius: -2,
      offset: Offset(0, 2),
    ),
  ];
  static const level3 = [
    BoxShadow(
      color: Color(0x1F1E40AF),
      blurRadius: 24,
      spreadRadius: -4,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      spreadRadius: -2,
      offset: Offset(0, 4),
    ),
  ];
}

ThemeData appTheme() {
  const font = 'PlusJakartaSans';
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.primary,
    secondary: AppColors.secondary,
    tertiary: AppColors.tertiary,
    error: AppColors.error,
    errorContainer: AppColors.errorContainer,
    surface: Colors.white,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerHighest: AppColors.tonal,
    outline: AppColors.outline,
    outlineVariant: AppColors.outline,
  );
  final base = ThemeData(useMaterial3: true, fontFamily: font).textTheme;
  final text = base
      .copyWith(
        headlineLarge: const TextStyle(
          fontSize: 24,
          height: 32 / 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.48,
        ),
        headlineMedium: const TextStyle(
          fontSize: 22,
          height: 28 / 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.44,
        ),
        headlineSmall: const TextStyle(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.18,
        ),
        titleLarge: const TextStyle(
          fontSize: 18,
          height: 24 / 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.18,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          height: 22 / 16,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: const TextStyle(fontSize: 16, height: 24 / 16),
        bodyMedium: const TextStyle(fontSize: 14, height: 20 / 14),
        bodySmall: const TextStyle(
          fontSize: 12,
          height: 18 / 12,
          color: AppColors.textSecondary,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          height: 20 / 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.14,
        ),
        labelMedium: const TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.24,
        ),
        labelSmall: const TextStyle(
          fontSize: 11,
          height: 14 / 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.33,
        ),
      )
      .apply(
        fontFamily: font,
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      );
  final rounded =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  const buttonText = TextStyle(
    fontFamily: font,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.14,
  );
  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  return ThemeData(
    useMaterial3: true,
    fontFamily: font,
    colorScheme: scheme,
    textTheme: text,
    scaffoldBackgroundColor: AppColors.canvas,
    dividerColor: AppColors.outline,
    dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      shape: const Border(bottom: BorderSide(color: AppColors.outlineSoft)),
      titleTextStyle: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.textSecondary,
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.tonal,
        disabledForegroundColor: AppColors.textTertiary,
        elevation: 2,
        shadowColor: AppColors.secondary.withValues(alpha: 0.35),
        minimumSize: const Size(0, 48),
        textStyle: buttonText.copyWith(fontWeight: FontWeight.w700),
        shape: rounded,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        foregroundColor: AppColors.primary,
        backgroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        textStyle: buttonText.copyWith(fontSize: 13),
        side: const BorderSide(color: AppColors.primaryBorder),
        shape: rounded,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: buttonText.copyWith(fontSize: 13),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.primaryContainer,
      side: const BorderSide(color: AppColors.outline),
      shape: const StadiumBorder(),
      showCheckmark: false,
      labelStyle: const TextStyle(
        fontFamily: font,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: font,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIconColor: AppColors.textTertiary,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      counterStyle:
          const TextStyle(color: AppColors.textTertiary, fontSize: 11),
      border: inputBorder(AppColors.outline),
      enabledBorder: inputBorder(AppColors.outline),
      focusedBorder: inputBorder(AppColors.secondary, 1.5),
      errorBorder: inputBorder(AppColors.error),
      focusedErrorBorder: inputBorder(AppColors.error, 1.5),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      thumbColor: WidgetStateProperty.all(Colors.white),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? AppColors.secondary
            : const Color(0xFFCBD5E1),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: const TextStyle(fontFamily: font, color: Colors.white),
      shape: rounded,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primaryContainer,
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => TextStyle(
          fontFamily: font,
          fontSize: 11,
          fontWeight: s.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w500,
          color: s.contains(WidgetState.selected)
              ? AppColors.secondary
              : AppColors.textSecondary,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected)
              ? AppColors.secondary
              : AppColors.textSecondary,
        ),
      ),
    ),
  );
}
