import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  // ✅ اجعل القيمة الابتدائية Light لضمان عدم وجود وميض أو وضع مختلط عند البدء
  ThemeMode _themeMode = ThemeMode.light; 

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  // ✅ دالة لتحميل الإعداد المحفوظ عند بدء التطبيق
  Future<void> loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      // إذا كان هناك إعداد محفوظ سابقاً، استخدمه
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else if (savedTheme == 'light') {
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = ThemeMode.light; // احتياطي
      }
    } else {
      // ✅✅✅ التصحيح هنا: إذا لم يكن هناك إعداد محفوظ (أول تشغيل)، اجعله Light Mode
      _themeMode = ThemeMode.light; 
    }
    
    notifyListeners(); // تحديث الواجهة بعد التحميل
  }

  // ✅ دالة لحفظ الإعداد عند التغيير
  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // نختصر الاسم ليكون 'light' أو 'dark' فقط بدلاً من 'ThemeMode.light'
    await prefs.setString(_themeKey, mode.toString().split('.').last);
  }

  void toggleTheme() {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  void setLight() {
    _themeMode = ThemeMode.light;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  void setDark() {
    _themeMode = ThemeMode.dark;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }
}