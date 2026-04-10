import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/providers/user_provider.dart';
import 'package:minipr/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/settings_toggle_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
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
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Settings',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ACCOUNT ──
                    _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsNavItem(
                          iconBg: AppColors.purpleLight.withOpacity(isDark ? 0.15 : 1),
                          iconColor: AppColors.purple,
                          icon: Icons.manage_accounts_outlined,
                          title: 'Account Type',
                          subtitle: 'Étudiant',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── PREFERENCE ──
                    _SectionLabel(label: 'PREFERENCE'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight
                                      .withOpacity(isDark ? 0.15 : 1),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.dark_mode_outlined,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Night Mode',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              SettingsToggleItem(
                                title: '',
                                initialValue: isDark,
                                onChanged: (_) {
                                  context.read<ThemeProvider>().toggleTheme();
                                },
                              ),
                            ],
                          ),
                        ),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _SettingsNavItem(
                          iconBg: c.iconBg,
                          iconColor: c.textSecondary,
                          icon: Icons.notifications_outlined,
                          title: 'Notifications Center',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── NOTIFICATION SETTINGS ──
                    _SectionLabel(label: 'NOTIFICATION SETTINGS'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _ToggleRow(title: 'Push Notifications', initialValue: true),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _ToggleRow(title: 'Email Summaries', initialValue: false),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _ToggleRow(title: 'Job Alerts', initialValue: true),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── PRIVACY & SECURITY ──
                    _SectionLabel(label: 'PRIVACY & SECURITY'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsNavItem(
                          iconBg: c.iconBg,
                          iconColor: c.textSecondary,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () {},
                        ),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _SettingsNavItem(
                          iconBg: c.iconBg,
                          iconColor: c.textSecondary,
                          icon: Icons.help_outline_rounded,
                          title: 'Help Center',
                          onTap: () {},
                        ),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _SettingsNavItem(
                          iconBg: c.iconBg,
                          iconColor: c.textSecondary,
                          icon: Icons.info_outline_rounded,
                          title: 'About Us',
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Log Out ──
                    GestureDetector(
                      onTap: () async {
                        try {
                          await FirebaseAuth.instance.signOut();
                          context.read<UserProvider>().clearUser();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/home',
                            (route) => false,
                          );
                        } catch (e) {
                          debugPrint('Logout error: $e');
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.redLight.withOpacity(isDark ? 0.12 : 1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.red, size: 20),
                            SizedBox(width: 16),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal Helper Widgets ──

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        label,
        style: TextStyle(
          color: context.colors.textMuted,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsNavItem extends StatelessWidget {
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _SettingsNavItem({
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
              ],
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: c.textMuted, size: 16),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  final String title;
  final bool initialValue;
  const _ToggleRow({required this.title, this.initialValue = false});

  @override
  State<_ToggleRow> createState() => _ToggleRowState();
}

class _ToggleRowState extends State<_ToggleRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _value = !_value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 24,
              padding: EdgeInsets.only(
                left: _value ? 18 : 3,
                right: _value ? 3 : 18,
                top: 3,
                bottom: 3,
              ),
              decoration: BoxDecoration(
                color: _value ? AppColors.primary : c.border,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
