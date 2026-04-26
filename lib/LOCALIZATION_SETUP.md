# ── Required pubspec.yaml additions ──────────────────────────
#
# Add these two packages to your pubspec.yaml dependencies:
#
# dependencies:
#   flutter_localizations:
#     sdk: flutter
#   shared_preferences: ^2.2.3
#
# Also add this to the flutter: section:
#
# flutter:
#   generate: false   # we use manual l10n, not codegen
#
# Then run:
#   flutter pub get
#
# ─────────────────────────────────────────────────────────────
# New files added:
#
#   lib/l10n/
#     app_en.dart             ← English strings
#     app_fr.dart             ← French strings
#     app_ar.dart             ← Arabic strings
#     app_localizations.dart  ← AppLocalizations class + delegate
#
#   lib/providers/
#     locale_provider.dart    ← ChangeNotifier that persists locale
#
#   lib/screens/shared/
#     settings_screen.dart    ← Settings page with language switcher
#
#   lib/main.dart             ← Updated with LocaleProvider + delegates
#
# ─────────────────────────────────────────────────────────────
# How to use translations in any screen:
#
#   import '../../l10n/app_localizations.dart';
#
#   final l = AppLocalizations.of(context);
#   Text(l.dashboard)
#   Text(l.settings)
#   Text(l.myProfile)
#   // etc.
#
# ─────────────────────────────────────────────────────────────
