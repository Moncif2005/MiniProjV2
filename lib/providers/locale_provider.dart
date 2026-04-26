import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// Call this once at app startup before runApp
  Future<void> loadLocalePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'en';
    _locale = Locale(code);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  String get languageCode => _locale.languageCode;

  bool get isRtl => _locale.languageCode == 'ar';
}
