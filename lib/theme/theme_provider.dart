import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light; // القيمة الافتراضية مؤقتاً

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  // ✅ دالة لتحميل الإعداد المحفوظ عند بدء التطبيق
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    } else {
      _themeMode = ThemeMode.system; // الافتراضي إذا لم يكن هناك حفظ سابق
    }
    
    notifyListeners(); // تحديث الواجهة بعد التحميل
  }

  // ✅ دالة لحفظ الإعداد عند التغيير
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.toString().split('.').last);
  }

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _saveThemePreference(_themeMode); // ✅ حفظ التغيير
    notifyListeners();
  }

  void setLight() {
    _themeMode = ThemeMode.light;
    _saveThemePreference(_themeMode); // ✅ حفظ التغيير
    notifyListeners();
  }

  void setDark() {
    _themeMode = ThemeMode.dark;
    _saveThemePreference(_themeMode); // ✅ حفظ التغيير
    notifyListeners();
  }
}