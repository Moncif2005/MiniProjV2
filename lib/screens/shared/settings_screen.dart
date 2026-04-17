import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // ✅ لأجل kReleaseMode
import 'package:minipr/providers/user_provider.dart';
import 'package:minipr/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/settings_toggle_item.dart';
import '../auth/phone_verification_screen.dart';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ACCOUNT ──
                    _SectionLabel(label: 'ACCOUNT'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _SettingsNavItem(
                          iconBg: AppColors.purpleLight.withOpacity(
                            isDark ? 0.15 : 1,
                          ),
                          iconColor: AppColors.purple,
                          icon: Icons.manage_accounts_outlined,
                          title: 'Account Type',
                          subtitle: 'Étudiant',
                          onTap: () {},
                        ),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        // ── Email Verification Row ──
                        _EmailVerificationItem(isDark: isDark),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        // ── Phone Verification Row ──
                        _PhoneVerificationItem(isDark: isDark),
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
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(
                                    isDark ? 0.15 : 1,
                                  ),
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
                          onTap: () =>
                              Navigator.pushNamed(context, '/notifications'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── NOTIFICATION SETTINGS ──
                    _SectionLabel(label: 'NOTIFICATION SETTINGS'),
                    const SizedBox(height: 12),
                    _SettingsCard(
                      children: [
                        _PushNotifToggle(),
                        Divider(color: c.border, thickness: 1.24, height: 0),
                        _ToggleRow(
                          title: 'Email Summaries',
                          initialValue: false,
                        ),
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
                          color: AppColors.redLight.withOpacity(
                            isDark ? 0.12 : 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.logout_rounded,
                              color: AppColors.red,
                              size: 20,
                            ),
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

// ── Email Verification Item ──
class _EmailVerificationItem extends StatefulWidget {
  final bool isDark;
  const _EmailVerificationItem({required this.isDark});

  @override
  State<_EmailVerificationItem> createState() => _EmailVerificationItemState();
}

class _EmailVerificationItemState extends State<_EmailVerificationItem> {
  bool _sending = false;
  bool _sent = false;

  bool get _isVerified =>
      FirebaseAuth.instance.currentUser?.emailVerified ?? false;

  Future<void> _sendVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _sending) return;

    setState(() => _sending = true);
    try {
      await user.reload();
      if (user.emailVerified) {
        setState(() => _sending = false);
        return;
      }
      await user.sendEmailVerification();
      setState(() {
        _sent = true;
        _sending = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Verification email sent!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _sending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Text(
              e.message ?? 'Failed to send verification email.',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _sending = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      setState(() => _sending = false);
      if (mounted) {
        final verified =
            FirebaseAuth.instance.currentUser?.emailVerified ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: verified ? AppColors.green : AppColors.orange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            content: Text(
              verified
                  ? 'Email verified successfully!'
                  : 'Email not yet verified. Please check your inbox.',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }
    } catch (_) {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final verified = _isVerified;

    final Color iconBg = verified
        ? AppColors.greenLight.withOpacity(widget.isDark ? 0.15 : 1)
        : AppColors.primaryLight.withOpacity(widget.isDark ? 0.15 : 1);
    final Color iconColor = verified ? AppColors.green : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              verified ? Icons.mark_email_read_outlined : Icons.email_outlined,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Email Verification',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: verified
                            ? AppColors.greenLight.withOpacity(
                                widget.isDark ? 0.2 : 1,
                              )
                            : AppColors.redLight.withOpacity(
                                widget.isDark ? 0.2 : 1,
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            verified
                                ? Icons.verified_rounded
                                : Icons.error_outline_rounded,
                            size: 11,
                            color: verified ? AppColors.green : AppColors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            verified ? 'Verified' : 'Not Verified',
                            style: TextStyle(
                              color: verified ? AppColors.green : AppColors.red,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!verified) ...[
            const SizedBox(width: 8),
            _sending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : _sent
                ? GestureDetector(
                    onTap: _checkVerificationStatus,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(
                          widget.isDark ? 0.15 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Check',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: _sendVerification,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          ],
        ],
      ),
    );
  }
}

// ── Phone Verification Item ───────────────────────────────────────────────────
class _PhoneVerificationItem extends StatefulWidget {
  final bool isDark;
  const _PhoneVerificationItem({required this.isDark});

  @override
  State<_PhoneVerificationItem> createState() => _PhoneVerificationItemState();
}

class _PhoneVerificationItemState extends State<_PhoneVerificationItem> {
  bool _checking = false;

  bool get _isLinked {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    return user.providerData.any(
      (p) => p.providerId == PhoneAuthProvider.PROVIDER_ID,
    );
  }

  String? get _linkedPhone {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      return user.providerData
          .firstWhere((p) => p.providerId == PhoneAuthProvider.PROVIDER_ID)
          .phoneNumber;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openVerificationScreen() async {
    setState(() => _checking = true);
    await FirebaseAuth.instance.currentUser?.reload();
    if (!mounted) return;
    setState(() => _checking = false);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final linked = _isLinked;
    final phone = _linkedPhone;

    final Color iconBg = linked
        ? AppColors.greenLight.withOpacity(widget.isDark ? 0.15 : 1)
        : AppColors.purpleLight.withOpacity(widget.isDark ? 0.15 : 1);
    final Color iconColor = linked ? AppColors.green : AppColors.purple;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              linked ? Icons.phone_enabled_outlined : Icons.phone_outlined,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Verification',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: linked
                            ? AppColors.greenLight.withOpacity(
                                widget.isDark ? 0.2 : 1,
                              )
                            : AppColors.redLight.withOpacity(
                                widget.isDark ? 0.2 : 1,
                              ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            linked
                                ? Icons.verified_rounded
                                : Icons.error_outline_rounded,
                            size: 11,
                            color: linked ? AppColors.green : AppColors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            linked
                                ? (phone != null ? phone : 'Verified')
                                : 'Not Added',
                            style: TextStyle(
                              color: linked ? AppColors.green : AppColors.red,
                              fontSize: 11,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (linked) ...[
                      const SizedBox(width: 6),
                      Text(
                        '(optional)',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _checking
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.purple,
                  ),
                )
              : GestureDetector(
                  onTap: _openVerificationScreen,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: linked
                          ? AppColors.primaryLight.withOpacity(
                              widget.isDark ? 0.15 : 1,
                            )
                          : AppColors.purple,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      linked ? 'Change' : 'Add',
                      style: TextStyle(
                        color: linked ? AppColors.primary : Colors.white,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
        ],
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

// ── Generic toggle row ─────────────────────────────
class _ToggleRow extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;
  const _ToggleRow({
    required this.title,
    this.initialValue = false,
    this.onChanged,
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
            onTap: () {
              setState(() => _value = !_value);
              widget.onChanged?.call(_value);
            },
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

// ── Push Notifications toggle — wired to FCM ─────────────────────────────────
class _PushNotifToggle extends StatefulWidget {
  @override
  State<_PushNotifToggle> createState() => _PushNotifToggleState();
}

class _PushNotifToggleState extends State<_PushNotifToggle> {
  bool _enabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentState();
  }

  Future<void> _loadCurrentState() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final notifEnabled = doc.data()?['notificationsEnabled'] as bool? ?? true;

    if (mounted)
      setState(() {
        _enabled = notifEnabled;
        _loading = false;
      });
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (value) {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'fcmToken': token,
          'notificationsEnabled': true,
        });
      }
    } else {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': FieldValue.delete(),
        'notificationsEnabled': false,
      });
      await FirebaseMessaging.instance.deleteToken();
    }
  }

  // ✅ ✅ ✅ دالة اختبار كتابة الإشعارات ✅ ✅ ✅
  // Future<void> _testNotificationWrite() async {
  //   final uid = FirebaseAuth.instance.currentUser?.uid;
  //   if (uid == null) return;

  //   try {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(uid)
  //         .collection('notifications')
  //         .add({
  //           'title': '🧪 Test Notification',
  //           'body':
  //               'If you see this in your notifications screen, the rules are working!',
  //           'type': 'system',
  //           'isUnread': true,
  //           'createdAt': FieldValue.serverTimestamp(),
  //           'payload': {'test': true},
  //         });

  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('✅ Write successful! Check your notifications.'),
  //           backgroundColor: AppColors.green,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('❌ Test failed: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('❌ Error: $e'),
  //           backgroundColor: AppColors.red,
  //           behavior: SnackBarBehavior.floating,
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Push Notifications',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Push Notifications',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
          Row(
            children: [
              // Toggle switch
              GestureDetector(
                onTap: () => _toggle(!_enabled),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 24,
                  padding: EdgeInsets.only(
                    left: _enabled ? 18 : 3,
                    right: _enabled ? 3 : 18,
                    top: 3,
                    bottom: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _enabled ? AppColors.primary : c.border,
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
              // // ✅ زر الاختبار (يظهر فقط في وضع التطوير)
              // if (!kReleaseMode)
              //   GestureDetector(
              //     onTap: _testNotificationWrite,
              //     child: Container(
              //       margin: const EdgeInsets.only(left: 8),
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 8,
              //         vertical: 4,
              //       ),
              //       decoration: BoxDecoration(
              //         color: Colors.orange,
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //       child: const Text(
              //         '🧪 Test',
              //         style: TextStyle(color: Colors.white, fontSize: 10),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ],
      ),
    );
  }
}
