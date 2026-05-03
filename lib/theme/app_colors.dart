import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AppColors {
  // ── Brand ──
  static const primary        = Color(0xFF155DFC);
  static const primaryLight   = Color(0xFFDBEAFE);
  static const primaryDark    = Color(0xFF2B7FFF);

  // ── Light Mode ──
  static const lightBg            = Color(0xFFF8FAFF);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightBorder        = Color(0xFFEEF2FF);
  static const lightTextPrimary   = Color(0xFF0F1728);
  static const lightTextSecondary = Color(0xFF5B6A8A);
  static const lightTextMuted     = Color(0xFFA0AABF);
  static const lightInputBg       = Color(0xFFFFFFFF);
  static const lightCardBg        = Color(0xFFFFFFFF);
  static const lightNavBg         = Color(0xFFFFFFFF);
  static const lightIconBg        = Color(0xFFF0F4FF);

  // ── Dark Mode — deep space navy ──
  static const darkBg             = Color(0xFF080C1A);
  static const darkSurface        = Color(0xFF111827);
  static const darkSurface2       = Color(0xFF1A2236);
  static const darkBorder         = Color(0xFF1E2D4A);
  static const darkBorderAccent   = Color(0xFF2A3F66);
  static const darkTextPrimary    = Color(0xFFE2EAF8);
  static const darkTextSecondary  = Color(0xFF6E90C0);
  static const darkTextMuted      = Color(0xFF384D6B);
  static const darkInputBg        = Color(0xFF0D1525);
  static const darkCardBg         = Color(0xFF111827);
  static const darkNavBg          = Color(0xFF0D1525);
  static const darkIconBg         = Color(0xFF1A2236);

  // ── Dark brand ──
  static const darkPrimary        = Color(0xFF3B82F6);
  static const darkPrimaryLight   = Color(0xFF1E3A6E);
  static const darkPrimaryHover   = Color(0xFF60A5FA);
  static const darkPrimaryGlow    = Color(0x333B82F6);

  // ── Semantic ──
  static const green       = Color(0xFF10B981);
  static const greenLight  = Color(0xFFD1FAE5);
  static const red         = Color(0xFFEF4444);
  static const redLight    = Color(0xFFFEE2E2);
  static const orange      = Color(0xFFF97316);
  static const orangeLight = Color(0xFFFFEDD5);
  static const yellow      = Color(0xFFF59E0B);
  static const yellowLight = Color(0xFFFEF3C7);
  static const purple      = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFEDE9FE);
  static const cyan        = Color(0xFF06B6D4);
  static const cyanLight   = Color(0xFFCCFBF1);
  static const pink        = Color(0xFFEC4899);
  static const pinkLight   = Color(0xFFFCE7F3);

  // ── Gradients ──
  static const gradientBlue   = [Color(0xFF2B7FFF), Color(0xFF4F39F6)];
  static const gradientGreen  = [Color(0xFF10B981), Color(0xFF059669)];
  static const gradientOrange = [Color(0xFFF97316), Color(0xFFEF4444)];
  static const gradientPurple = [Color(0xFF8B5CF6), Color(0xFFEC4899)];
  static const gradientCyan   = [Color(0xFF06B6D4), Color(0xFF3B82F6)];
  static const gradientGold   = [Color(0xFFF59E0B), Color(0xFFF97316)];
}

// ── Resolved palette (switches based on dark/light) ──
class ThemeColors {
  final bool isDark;
  const ThemeColors(this.isDark);

  Color get bg            => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get surface       => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surface2      => isDark ? AppColors.darkSurface2 : const Color(0xFFF5F8FF);
  Color get border        => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get borderAccent  => isDark ? AppColors.darkBorderAccent : const Color(0xFFD5E3FF);
  Color get textPrimary   => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted     => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get inputBg       => isDark ? AppColors.darkInputBg : AppColors.lightInputBg;
  Color get cardBg        => isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
  Color get navBg         => isDark ? AppColors.darkNavBg : AppColors.lightNavBg;
  Color get iconBg        => isDark ? AppColors.darkIconBg : AppColors.lightIconBg;

  Color get primary       => isDark ? AppColors.darkPrimary : AppColors.primary;
  Color get primaryLight  => isDark ? AppColors.darkPrimaryLight : AppColors.primaryLight;
  Color get primaryGlow   => isDark ? AppColors.darkPrimaryGlow : AppColors.primary.withOpacity(0.12);
  Color get green         => AppColors.green;
  Color get greenLight    => isDark ? AppColors.green.withOpacity(0.15) : AppColors.greenLight;
  Color get red           => AppColors.red;
  Color get redLight      => isDark ? AppColors.red.withOpacity(0.15) : AppColors.redLight;
  Color get purple        => AppColors.purple;
  Color get purpleLight   => isDark ? AppColors.purple.withOpacity(0.15) : AppColors.purpleLight;
  Color get orange        => AppColors.orange;
  Color get orangeLight   => isDark ? AppColors.orange.withOpacity(0.15) : AppColors.orangeLight;
  Color get yellow        => AppColors.yellow;
  Color get cyan          => AppColors.cyan;
  Color get cyanLight     => isDark ? AppColors.cyan.withOpacity(0.15) : AppColors.cyanLight;
  Color get pink          => AppColors.pink;
}

// ── BuildContext extension ──
extension ThemeContextExtension on BuildContext {
  ThemeColors get colors {
    final dark = watch<ThemeProvider>().isDark;
    return ThemeColors(dark);
  }
  bool get isDark => watch<ThemeProvider>().isDark;
}
