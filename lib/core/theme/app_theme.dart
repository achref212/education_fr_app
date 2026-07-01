import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract class AppTheme {
  AppTheme._();

  static ThemeData get light => _buildTheme(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfacePrimary: AppColors.lightSurfacePrimary,
        onBackground: AppColors.lightBodyPrimary,
        onSurface: AppColors.lightBodyPrimary,
        secondary: AppColors.lightBodySecondary,
        divider: AppColors.lightDivider,
        statusBarStyle: SystemUiOverlayStyle.dark,
      );

  static ThemeData get dark => _buildTheme(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfacePrimary: AppColors.darkSurfacePrimary,
        onBackground: AppColors.darkBodyPrimary,
        onSurface: AppColors.darkBodyPrimary,
        secondary: AppColors.darkBodySecondary,
        divider: AppColors.darkDivider,
        statusBarStyle: SystemUiOverlayStyle.light,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfacePrimary,
    required Color onBackground,
    required Color onSurface,
    required Color secondary,
    required Color divider,
    required SystemUiOverlayStyle statusBarStyle,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.primary,
      onSecondary: AppColors.onPrimary,
      error: AppColors.error,
      onError: AppColors.onPrimary,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfacePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      dividerColor: divider,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onBackground,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: statusBarStyle.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: AppTextStyles.titleLarge.copyWith(
          color: onBackground,
        ),
        iconTheme: IconThemeData(color: onBackground),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.calloutBold,
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.calloutBold,
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.bodyMedium.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // ── InputDecoration ────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: secondary),
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ── BottomSheet ────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // ── Typography ─────────────────────────────────────────────────────────
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: onBackground),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(color: onBackground),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: onBackground),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: onBackground),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: onBackground),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: onBackground),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: onBackground),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: secondary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: secondary),
      ),

      // ── Icon ───────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: isDark ? AppColors.darkBodyPrimary : AppColors.lightBodyPrimary),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        labelStyle: AppTextStyles.bodySmall.copyWith(color: onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
