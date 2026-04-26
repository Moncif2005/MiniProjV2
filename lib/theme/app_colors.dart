import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class AppColors {
  // ── Brand ──
  static const primary        = Color(0xFF155DFC);
  static const primaryLight   = Color(0xFFDBEAFE);
  static const primaryDark    = Color(0xFF2B7FFF);

  // ── Light Mode ──
  static const lightBg            = Color(0xFFFAFAFA);
  static const lightSurface       = Color(0xFFFFFFFF);
  static const lightBorder        = Color(0xFFF5F5F5);
  static const lightTextPrimary   = Color(0xFF171717);
  static const lightTextSecondary = Color(0xFF737373);
  static const lightTextMuted     = Color(0xFFA1A1A1);
  static const lightInputBg       = Color(0xFFFFFFFF);
  static const lightCardBg        = Color(0xFFFFFFFF);
  static const lightNavBg         = Color(0xFFFFFFFF);
  static const lightIconBg        = Color(0xFFFAFAFA);

  // ── Dark Mode ──
  static const darkBg             = Color(0xFF0A0A0A);
  static const darkSurface        = Color(0xFF171717);
  static const darkBorder         = Color(0xFF262626);
  static const darkTextPrimary    = Color(0xFFFAFAFA);
  static const darkTextSecondary  = Color(0xFFA1A1A1);
  static const darkTextMuted      = Color(0xFF737373);
  static const darkInputBg        = Color(0xFF1C1C1C);
  static const darkCardBg         = Color(0xFF171717);
  static const darkNavBg          = Color(0xFF111111);
  static const darkIconBg         = Color(0xFF262626);

  // ── Semantic ──
  static const green       = Color(0xFF00A63E);
  static const greenLight  = Color(0xFFDCFCE7);
  static const red         = Color(0xFFFB2C36);
  static const redLight    = Color(0xFFFEF2F2);
  static const orange      = Color(0xFFF54900);
  static const yellow      = Color(0xFFD08700);
  static const purple      = Color(0xFF9810FA);
  static const purpleLight = Color(0xFFF3E8FF);
  static const cyan        = Color(0xFF0092B8);
  static const cyanLight   = Color(0xFFCEFAFE);

  // ── Gradients ──
  static const gradientBlue = [
    Color(0xFF2B7FFF),
    Color(0xFF4F39F6),
  ];
  static const gradientGreen = [
    Color(0xFF00C950),
    Color(0xFF009966),
  ];
  static const gradientOrange = [
    Color(0xFFFF6900),
    Color(0xFFE7000B),
  ];
  static const gradientPurple = [
    Color(0xFFAD46FF),
    Color(0xFFE60076),
  ];
}

// ── Resolved palette (switches based on dark/light) ──
class ThemeColors {
  final bool isDark;
  const ThemeColors(this.isDark);

  Color get bg            => isDark
      ? AppColors.darkBg
      : AppColors.lightBg;

  Color get surface       => isDark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

  Color get border        => isDark
      ? AppColors.darkBorder
      : AppColors.lightBorder;

  Color get textPrimary   => isDark
      ? AppColors.darkTextPrimary
      : AppColors.lightTextPrimary;

  Color get textSecondary => isDark
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;

  Color get textMuted     => isDark
      ? AppColors.darkTextMuted
      : AppColors.lightTextMuted;

  Color get inputBg       => isDark
      ? AppColors.darkInputBg
      : AppColors.lightInputBg;

  Color get cardBg        => isDark
      ? AppColors.darkCardBg
      : AppColors.lightCardBg;

  Color get navBg         => isDark
      ? AppColors.darkNavBg
      : AppColors.lightNavBg;

  Color get iconBg        => isDark
      ? AppColors.darkIconBg
      : AppColors.lightIconBg;

  // ── Always the same regardless of theme ──
  Color get primary       => AppColors.primary;
  Color get primaryLight  => AppColors.primaryLight;
  Color get green         => AppColors.green;
  Color get greenLight    => AppColors.greenLight;
  Color get red           => AppColors.red;
  Color get redLight      => AppColors.redLight;
  Color get purple        => AppColors.purple;
  Color get purpleLight   => AppColors.purpleLight;
  Color get orange        => AppColors.orange;
  Color get yellow        => AppColors.yellow;
  Color get cyan          => AppColors.cyan;
  Color get cyanLight     => AppColors.cyanLight;
}

// ── BuildContext extension — use context.colors / context.isDark anywhere ──
extension ThemeContextExtension on BuildContext {
  ThemeColors get colors {
    final dark = watch<ThemeProvider>().isDark;
    return ThemeColors(dark);
  }

  bool get isDark => watch<ThemeProvider>().isDark;
}