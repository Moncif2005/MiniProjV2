import 'package:flutter/material.dart';
import '../../widgets/settings_toggle_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          children: [

            // ── App Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                              width: 1.24,
                              color: Color(0xFFF5F5F5)),
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
                      child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: Color(0xFF171717)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      color: Color(0xFF171717),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── ACCOUNT ──
                    _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _SettingsNavItem(
                        iconBg: const Color(0xFFFAF5FF),
                        iconColor: const Color(0xFF9810FA),
                        icon: Icons.manage_accounts_outlined,
                        title: 'Account Type',
                        subtitle: 'Étudiant',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── PREFERENCE ──
                    _SectionLabel(label: 'PREFERENCE'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius:
                                    BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                  Icons.dark_mode_outlined,
                                  color: Color(0xFF155DFC),
                                  size: 18),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Night Mode',
                                style: TextStyle(
                                  color: Color(0xFF404040),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            SettingsToggleItem(
                              title: '',
                              initialValue: false,
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                          color: Color(0xFFFAFAFA),
                          thickness: 1.24,
                          height: 0),
                      _SettingsNavItem(
                        iconBg: const Color(0xFFFAFAFA),
                        iconColor: const Color(0xFF737373),
                        icon: Icons.notifications_outlined,
                        title: 'Notifications Center',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── NOTIFICATION SETTINGS ──
                    _SectionLabel(label: 'NOTIFICATION SETTINGS'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _ToggleRow(
                          title: 'Push Notifications',
                          initialValue: true),
                      const Divider(
                          color: Color(0xFFFAFAFA),
                          thickness: 1.24,
                          height: 0),
                      _ToggleRow(
                          title: 'Email Summaries',
                          initialValue: false),
                      const Divider(
                          color: Color(0xFFFAFAFA),
                          thickness: 1.24,
                          height: 0),
                      _ToggleRow(
                          title: 'Job Alerts', initialValue: true),
                    ]),
                    const SizedBox(height: 24),

                    // ── PRIVACY & SECURITY ──
                    _SectionLabel(label: 'PRIVACY & SECURITY'),
                    const SizedBox(height: 12),
                    _SettingsCard(children: [
                      _SettingsNavItem(
                        iconBg: const Color(0xFFFAFAFA),
                        iconColor: const Color(0xFF737373),
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {},
                      ),
                      const Divider(
                          color: Color(0xFFFAFAFA),
                          thickness: 1.24,
                          height: 0),
                      _SettingsNavItem(
                        iconBg: const Color(0xFFFAFAFA),
                        iconColor: const Color(0xFF737373),
                        icon: Icons.help_outline_rounded,
                        title: 'Help Center',
                        onTap: () {},
                      ),
                      const Divider(
                          color: Color(0xFFFAFAFA),
                          thickness: 1.24,
                          height: 0),
                      _SettingsNavItem(
                        iconBg: const Color(0xFFFAFAFA),
                        iconColor: const Color(0xFF737373),
                        icon: Icons.info_outline_rounded,
                        title: 'About Us',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // ── Log Out ──
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/signup', (route) => false),
                      child: Container(
                        width: double.infinity,
                        height: 64,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.logout_rounded,
                                color: Color(0xFFE7000B), size: 20),
                            SizedBox(width: 16),
                            Text(
                              'Log Out',
                              style: TextStyle(
                                color: Color(0xFFE7000B),
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
        style: const TextStyle(
          color: Color(0xFFA1A1A1),
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
    return Container(
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(
              width: 1.24, color: Color(0xFFF5F5F5)),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
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
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 16),
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
                      style: const TextStyle(
                        color: Color(0xFF404040),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 12,
                          fontFamily: 'Inter',
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Color(0xFFA1A1A1), size: 16),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatefulWidget {
  final String title;
  final bool initialValue;
  const _ToggleRow(
      {required this.title, this.initialValue = false});

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
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.title,
            style: const TextStyle(
              color: Color(0xFF404040),
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
                color: _value
                    ? const Color(0xFF155DFC)
                    : const Color(0xFFE5E5E5),
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