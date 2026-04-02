import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentNavIndex = 3;

  @override
  Widget build(BuildContext context) {
    final c    = context.colors;
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(context, '/learn', (r) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(context, '/offers', (r) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Profile',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 24,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Edit button — navigates to EditProfileScreen
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
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
                      child: Icon(Icons.edit_outlined, color: c.textSecondary, size: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Profile Card ──
              Container(
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  shadows: const [
                    BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
                    BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
                  ],
                ),
                child: Column(
                  children: [
                    // ── Gradient Banner ──
                    Container(
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.gradientBlue,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Column(
                        children: [
                          // ── Avatar ──
                          Transform.translate(
                            offset: const Offset(0, -48),
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
                                    padding: const EdgeInsets.all(4),
                                    child: ClipOval(
                                      child: user.avatarPath != null
                                          ? Image.file(File(user.avatarPath!), fit: BoxFit.cover)
                                          : Container(
                                              color: AppColors.primaryLight,
                                              child: Center(
                                                child: Text(
                                                  user.initials,
                                                  style: const TextStyle(
                                                    color: AppColors.primary,
                                                    fontSize: 28,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: c.surface, width: 2),
                                      ),
                                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // ── Name + Role ──
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                Text(
                                  user.name.isNotEmpty ? user.name : 'Your Name',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Show description if set, otherwise show email
                                Text(
                                  user.description.isNotEmpty
                                      ? user.description
                                      : (user.email.isNotEmpty ? user.email : 'Tap edit to update your profile'),
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 13,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // ── Role Badge ──
                                _RoleBadge(user: user),
                                const SizedBox(height: 12),
                                // ── Contact info (phone if set) ──
                                if (user.phone.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.phone_outlined, size: 13, color: c.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        user.phone,
                                        style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),

                          // ── Social Links (if set) ──
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: _SocialLinks(user: user, c: c),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Menu Items ──
              ProfileMenuItem(
                icon: Icons.workspace_premium_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'My Certificates',
                onTap: () => Navigator.pushNamed(context, '/certificates'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.history_rounded,
                iconBg: c.iconBg,
                iconColor: c.textSecondary,
                title: 'Learning History',
                onTap: () => Navigator.pushNamed(context, '/learning-history'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.work_outline_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Applied Jobs',
                onTap: () => Navigator.pushNamed(context, '/applied-jobs'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                iconBg: c.iconBg,
                iconColor: c.textSecondary,
                title: 'Parameters',
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.logout_rounded,
                iconBg: AppColors.redLight,
                iconColor: AppColors.red,
                title: 'Log Out',
                isDestructive: true,
                onTap: () {
                  context.read<UserProvider>().clearUser();
                  Navigator.pushNamedAndRemoveUntil(context, '/signup', (route) => false);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Role Badge ────────────────────────────────────────────────────────────────
class _RoleBadge extends StatelessWidget {
  final UserProvider user;
  const _RoleBadge({required this.user});

  @override
  Widget build(BuildContext context) {
    Color bg, color;
    switch (user.role) {
      case UserRole.enseignant:
        bg = AppColors.greenLight; color = AppColors.green;
        break;
      case UserRole.recruteur:
        bg = AppColors.purpleLight; color = AppColors.purple;
        break;
      default:
        bg = AppColors.primaryLight; color = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
      child: Text(
        user.roleLabel,
        style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ── Social Links ──────────────────────────────────────────────────────────────
class _SocialLinks extends StatelessWidget {
  final UserProvider user;
  final ThemeColors c;
  const _SocialLinks({required this.user, required this.c});

  @override
  Widget build(BuildContext context) {
    final hasAny = user.github.isNotEmpty || user.linkedin.isNotEmpty || user.facebook.isNotEmpty;
    if (!hasAny) return const SizedBox.shrink();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (user.github.isNotEmpty)
          _SocialIcon(icon: Icons.code_rounded, color: c.textSecondary, bg: c.iconBg),
        if (user.linkedin.isNotEmpty)
          _SocialIcon(icon: Icons.work_outline_rounded, color: const Color(0xFF0077B5), bg: const Color(0xFFE8F4FD)),
        if (user.facebook.isNotEmpty)
          _SocialIcon(icon: Icons.facebook_rounded, color: const Color(0xFF1877F2), bg: const Color(0xFFE7F0FF)),
      ],
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final Color color, bg;
  const _SocialIcon({required this.icon, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
