import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: c.textSecondary, size: 16),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    AppLocalizations.of(context).settings,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ══════════════════════════════════════
              // SECTION: Appearance
              // ══════════════════════════════════════
              _SectionHeader(c: c, title: AppLocalizations.of(context).appearance),
              const SizedBox(height: 10),

              _SettingsCard(
                c: c,
                children: [
                  // Dark Mode toggle
                  _ToggleTile(
                    c: c,
                    icon: Icons.dark_mode_outlined,
                    iconColor: AppColors.purple,
                    iconBg: AppColors.purpleLight,
                    title: AppLocalizations.of(context).darkMode,
                    value: themeProvider.isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══════════════════════════════════════
              // SECTION: Language
              // ══════════════════════════════════════
              _SectionHeader(c: c, title: AppLocalizations.of(context).language),
              const SizedBox(height: 10),

              _SettingsCard(
                c: c,
                children: [
                  _LanguageTile(
                    c: c,
                    code: 'en',
                    label: AppLocalizations.of(context).langEnglish,
                    emoji: '🇬🇧',
                    selected: localeProvider.languageCode == 'en',
                    onTap: () => localeProvider.setLocale(const Locale('en')),
                  ),
                  Divider(color: c.border, height: 1),
                  _LanguageTile(
                    c: c,
                    code: 'fr',
                    label: AppLocalizations.of(context).langFrench,
                    emoji: '🇫🇷',
                    selected: localeProvider.languageCode == 'fr',
                    onTap: () => localeProvider.setLocale(const Locale('fr')),
                  ),
                  Divider(color: c.border, height: 1),
                  _LanguageTile(
                    c: c,
                    code: 'ar',
                    label: AppLocalizations.of(context).langArabic,
                    emoji: '🇩🇿',
                    selected: localeProvider.languageCode == 'ar',
                    onTap: () => localeProvider.setLocale(const Locale('ar')),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══════════════════════════════════════
              // SECTION: Notifications
              // ══════════════════════════════════════
              _SectionHeader(c: c, title: AppLocalizations.of(context).notifications),
              const SizedBox(height: 10),

              _SettingsCard(
                c: c,
                children: [
                  _ToggleTile(
                    c: c,
                    icon: Icons.notifications_outlined,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryLight,
                    title: AppLocalizations.of(context).pushNotifications,
                    value: true,
                    onChanged: (_) {},
                  ),
                  Divider(color: c.border, height: 1),
                  _ToggleTile(
                    c: c,
                    icon: Icons.email_outlined,
                    iconColor: AppColors.green,
                    iconBg: AppColors.greenLight,
                    title: AppLocalizations.of(context).emailNotifications,
                    value: false,
                    onChanged: (_) {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══════════════════════════════════════
              // SECTION: Account
              // ══════════════════════════════════════
              _SectionHeader(c: c, title: AppLocalizations.of(context).account),
              const SizedBox(height: 10),

              _SettingsCard(
                c: c,
                children: [
                  _NavTile(
                    c: c,
                    icon: Icons.lock_outline_rounded,
                    iconColor: Colors.orange,
                    iconBg: Colors.orange.withOpacity(0.1),
                    title: AppLocalizations.of(context).changePassword,
                    onTap: () =>
                        Navigator.pushNamed(context, '/forgot-password'),
                  ),
                  Divider(color: c.border, height: 1),
                  _NavTile(
                    c: c,
                    icon: Icons.privacy_tip_outlined,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primaryLight,
                    title: AppLocalizations.of(context).privacyPolicy,
                    onTap: () {},
                  ),
                  Divider(color: c.border, height: 1),
                  _NavTile(
                    c: c,
                    icon: Icons.description_outlined,
                    iconColor: c.textSecondary,
                    iconBg: c.iconBg,
                    title: AppLocalizations.of(context).termsOfService,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ══════════════════════════════════════
              // SECTION: About
              // ══════════════════════════════════════
              _SectionHeader(c: c, title: AppLocalizations.of(context).about),
              const SizedBox(height: 10),

              _SettingsCard(
                c: c,
                children: [
                  _NavTile(
                    c: c,
                    icon: Icons.info_outline_rounded,
                    iconColor: AppColors.purple,
                    iconBg: AppColors.purpleLight,
                    title: '${AppLocalizations.of(context).version} 1.0.0',
                    onTap: () {},
                    showChevron: false,
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final ThemeColors c;
  final String title;
  const _SectionHeader({required this.c, required this.title});
  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: c.textSecondary,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );
}

class _SettingsCard extends StatelessWidget {
  final ThemeColors c;
  final List<Widget> children;
  const _SettingsCard({required this.c, required this.children});
  @override
  Widget build(BuildContext context) => Container(
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(18),
          ),
          shadows: const [
            BoxShadow(
                color: Color(0x08000000),
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );
}

class _ToggleTile extends StatelessWidget {
  final ThemeColors c;
  final IconData icon;
  final Color iconColor, iconBg;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({
    required this.c,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500)),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.purple,
          ),
        ]),
      );
}

class _LanguageTile extends StatelessWidget {
  final ThemeColors c;
  final String code, label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _LanguageTile({
    required this.c,
    required this.code,
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.purpleLight
                    : c.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: selected ? AppColors.purple : c.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w500)),
            ),
            if (selected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 14),
              )
            else
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: c.border, width: 1.5),
                ),
              ),
          ]),
        ),
      );
}

class _NavTile extends StatelessWidget {
  final ThemeColors c;
  final IconData icon;
  final Color iconColor, iconBg;
  final String title;
  final VoidCallback onTap;
  final bool showChevron;
  const _NavTile({
    required this.c,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.onTap,
    this.showChevron = true,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500)),
            ),
            if (showChevron)
              Icon(Icons.chevron_right_rounded,
                  color: c.textMuted, size: 20),
          ]),
        ),
      );
}
