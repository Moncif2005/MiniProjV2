import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Mixin for StatefulWidget states — gives access to
/// [c] (ThemeColors) and [isDark] without extra imports.
mixin ThemedScreen<T extends StatefulWidget> on State<T> {
  ThemeColors get c   => context.colors;
  bool get isDark     => context.isDark;
}