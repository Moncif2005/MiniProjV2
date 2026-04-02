import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/theme_provider.dart';
import '../../providers/user_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c             = context.colors;
    final themeProvider = context.watch<ThemeProvider>();
    final user          = context.watch<UserProvider>();
    final isDark        = themeProvider.isDark;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [

            // ── App Bar ──
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              decoration: BoxDecoration(
                color: c.surface,
                border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: ShapeDecoration(
                        color: c.bg,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Settings',
                      style: TextStyle(
                        color: c.textPrimary, fontSize: 20,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── ACCOUNT ──
                    _SectionLabel(label: 'ACCOUNT', c: c),
                    const SizedBox(height: 12),
                    _SettingsCard(c: c, children: [
                      _InfoRow(
                        c: c,
                        iconBg: AppColors.purpleLight,
                        iconColor: AppColors.purple,
                        icon: Icons.manage_accounts_outlined,
                        title: 'Account Type',
                        subtitle: user.roleLabel,
                      ),
                      _Divider(c: c),
                      _InfoRow(
                        c: c,
                        iconBg: AppColors.primaryLight,
                        iconColor: AppColors.primary,
                        icon: Icons.person_outline_rounded,
                        title: 'Name',
                        subtitle: user.name.isNotEmpty ? user.name : '—',
                      ),
                      _Divider(c: c),
                      _InfoRow(
                        c: c,
                        iconBg: c.iconBg,
                        iconColor: c.textSecondary,
                        icon: Icons.mail_outline_rounded,
                        title: 'Email',
                        subtitle: user.email.isNotEmpty ? user.email : '—',
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── APPEARANCE ──
                    _SectionLabel(label: 'APPEARANCE', c: c),
                    const SizedBox(height: 12),
                    _SettingsCard(c: c, children: [
                      // ── Dark Mode Toggle ──
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E2E)
                                    : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isDark
                                    ? Icons.dark_mode_rounded
                                    : Icons.light_mode_rounded,
                                color: isDark
                                    ? const Color(0xFF818CF8)
                                    : AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      color: c.textPrimary, fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    isDark ? 'Dark theme enabled' : 'Light theme enabled',
                                    style: TextStyle(
                                      color: c.textSecondary, fontSize: 12,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ── Real toggle connected to ThemeProvider ──
                            GestureDetector(
                              onTap: () =>
                                  context.read<ThemeProvider>().toggleTheme(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 48,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF818CF8)
                                      : c.border,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: AnimatedAlign(
                                  duration: const Duration(milliseconds: 250),
                                  alignment: isDark
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── NOTIFICATIONS ──
                    _SectionLabel(label: 'NOTIFICATIONS', c: c),
                    const SizedBox(height: 12),
                    _SettingsCard(c: c, children: [
                      _ToggleRow(c: c, title: 'Push Notifications',
                          subtitle: 'Receive app notifications',
                          initialValue: true),
                      _Divider(c: c),
                      _ToggleRow(c: c, title: 'Email Summaries',
                          subtitle: 'Weekly digest emails',
                          initialValue: false),
                      _Divider(c: c),
                      _ToggleRow(c: c, title: 'Job Alerts',
                          subtitle: 'New job opportunities',
                          initialValue: true),
                    ]),
                    const SizedBox(height: 24),

                    // ── SUPPORT ──
                    _SectionLabel(label: 'SUPPORT', c: c),
                    const SizedBox(height: 12),
                    _SettingsCard(c: c, children: [
                      _NavRow(
                        c: c,
                        iconBg: c.iconBg,
                        iconColor: c.textSecondary,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      _Divider(c: c),
                      _NavRow(
                        c: c,
                        iconBg: c.iconBg,
                        iconColor: c.textSecondary,
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        onTap: () {},
                      ),
                      _Divider(c: c),
                      _NavRow(
                        c: c,
                        iconBg: c.iconBg,
                        iconColor: c.textSecondary,
                        icon: Icons.info_outline_rounded,
                        title: 'About Us',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── Log Out ──
                    GestureDetector(
                      onTap: () {
                        context.read<UserProvider>().clearUser();
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/signup', (route) => false);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.redLight,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.red.withOpacity(0.2), width: 1),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: AppColors.red, size: 20),
                            SizedBox(width: 16),
                            Text('Log Out',
                                style: TextStyle(
                                  color: AppColors.red, fontSize: 16,
                                  fontFamily: 'Inter', fontWeight: FontWeight.w700,
                                )),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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

// ── Helpers ──

class _SectionLabel extends StatelessWidget {
  final String label;
  final ThemeColors c;
  const _SectionLabel({required this.label, required this.c});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 4),
    child: Text(label,
        style: TextStyle(
          color: c.textMuted, fontSize: 10,
          fontFamily: 'Inter', fontWeight: FontWeight.w900, letterSpacing: 1.2,
        )),
  );
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final ThemeColors c;
  const _SettingsCard({required this.children, required this.c});

  @override
  Widget build(BuildContext context) => Container(
    decoration: ShapeDecoration(
      color: c.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(width: 1.24, color: c.border),
        borderRadius: BorderRadius.circular(20),
      ),
      shadows: const [
        BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 2)),
      ],
    ),
    child: Column(children: children),
  );
}

class _Divider extends StatelessWidget {
  final ThemeColors c;
  const _Divider({required this.c});
  @override
  Widget build(BuildContext context) =>
      Divider(color: c.border, thickness: 1, height: 0, indent: 68);
}

class _InfoRow extends StatelessWidget {
  final ThemeColors c;
  final Color iconBg, iconColor;
  final IconData icon;
  final String title, subtitle;
  const _InfoRow({
    required this.c, required this.iconBg, required this.iconColor,
    required this.icon, required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    child: Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: iconBg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: TextStyle(
                color: c.textSecondary, fontSize: 11,
                fontFamily: 'Inter', fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: 2),
          Text(subtitle,
              style: TextStyle(
                color: c.textPrimary, fontSize: 15,
                fontFamily: 'Inter', fontWeight: FontWeight.w600,
              )),
        ]),
      ],
    ),
  );
}

class _NavRow extends StatelessWidget {
  final ThemeColors c;
  final Color iconBg, iconColor;
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _NavRow({
    required this.c, required this.iconBg, required this.iconColor,
    required this.icon, required this.title, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(title,
                style: TextStyle(
                  color: c.textPrimary, fontSize: 15,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600,
                )),
          ),
          Icon(Icons.chevron_right_rounded, color: c.textMuted, size: 20),
        ],
      ),
    ),
  );
}

class _ToggleRow extends StatefulWidget {
  final ThemeColors c;
  final String title;
  final String subtitle;
  final bool initialValue;
  const _ToggleRow({
    required this.c, required this.title,
    required this.subtitle, this.initialValue = false,
  });

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
    final c = widget.c;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.title,
                  style: TextStyle(
                    color: c.textPrimary, fontSize: 15,
                    fontFamily: 'Inter', fontWeight: FontWeight.w600,
                  )),
              Text(widget.subtitle,
                  style: TextStyle(
                    color: c.textSecondary, fontSize: 12, fontFamily: 'Inter',
                  )),
            ]),
          ),
          GestureDetector(
            onTap: () => setState(() => _value = !_value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 48, height: 28,
              decoration: BoxDecoration(
                color: _value ? AppColors.primary : c.border,
                borderRadius: BorderRadius.circular(100),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment:
                    _value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22, height: 22,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4, offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
