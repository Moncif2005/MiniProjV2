import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // ── Light Theme ──
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        background: AppColors.lightBg,
        surface: AppColors.lightSurface,
        onBackground: AppColors.lightTextPrimary,
        onSurface: AppColors.lightTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.lightBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardColor: AppColors.lightCardBg,
      dividerColor: AppColors.lightBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.lightBorder, width: 1.24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.lightBorder, width: 1.24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontFamily: 'Inter'),
        bodyLarge: TextStyle(
            color: AppColors.lightTextPrimary,
            fontFamily: 'Inter'),
        bodyMedium: TextStyle(
            color: AppColors.lightTextSecondary,
            fontFamily: 'Inter'),
      ),
    );
  }

  // ── Dark Theme ──
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        background: AppColors.darkBg,
        surface: AppColors.darkSurface,
        onBackground: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),
      scaffoldBackgroundColor: AppColors.darkBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      cardColor: AppColors.darkCardBg,
      dividerColor: AppColors.darkBorder,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.darkBorder, width: 1.24),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.darkBorder, width: 1.24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
              color: AppColors.primary, width: 1.5),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Inter'),
        bodyLarge: TextStyle(
            color: AppColors.darkTextPrimary,
            fontFamily: 'Inter'),
        bodyMedium: TextStyle(
            color: AppColors.darkTextSecondary,
            fontFamily: 'Inter'),
      ),
    );
  }
}