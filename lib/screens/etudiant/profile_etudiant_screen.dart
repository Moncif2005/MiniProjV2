import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/profile_menu_item.dart';

class ProfileEtudiantScreen extends StatefulWidget {
  const ProfileEtudiantScreen({super.key});
  @override
  State<ProfileEtudiantScreen> createState() => _ProfileEtudiantScreenState();
}

class _ProfileEtudiantScreenState extends State<ProfileEtudiantScreen> {
  int _currentNavIndex = 3;

  // ── Helper: Build initials avatar ──
  Widget _buildInitials(ThemeColors c, UserProvider user) {
    return Container(
      color: AppColors.primaryLight, // ✅ أزرق للطالب
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/etudiant/home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/etudiant/learn',
                (route) => false,
              );
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/offers',
                (route) => false,
              );
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
                      child: Icon(
                        Icons.edit_outlined,
                        color: c.textSecondary,
                        size: 18,
                      ),
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
                child: Column(
                  children: [
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
                            child: Stack(
                              children: [
                                Container(
                                  width: 96,
                                  height: 96,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.surface,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipOval(
                                    child:
                                        (user.avatarPath != null &&
                                            user.avatarPath!.isNotEmpty)
                                        ? (user.avatarPath!.startsWith('http')
                                              ? Image.network(
                                                  user.avatarPath!,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (_, child, progress) {
                                                    if (progress == null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child: CircularProgressIndicator(
                                                        value:
                                                            progress.expectedTotalBytes !=
                                                                null
                                                            ? progress.cumulativeBytesLoaded /
                                                                  (progress
                                                                          .expectedTotalBytes ??
                                                                      1)
                                                            : null,
                                                        color:
                                                            AppColors.primary,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildInitials(c, user),
                                                )
                                              : Image.file(
                                                  File(user.avatarPath!),
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      _buildInitials(c, user),
                                                ))
                                        : _buildInitials(c, user),
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
                                      border: Border.all(
                                        color: c.surface,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.edit_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Name + Role ──
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : 'Your Name',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Student & Lifelong Learner',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    user.roleLabel.isNotEmpty
                                        ? user.roleLabel
                                        : 'Étudiant',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // ── Stats ──
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatItem(
                                  value: '0',
                                  label: 'COURSES',
                                  textColor: c.textPrimary,
                                  labelColor: c.textMuted,
                                ),
                                Container(
                                  width: 1,
                                  height: 32,
                                  color: c.border,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                ),
                                _StatItem(
                                  value: '0',
                                  label: 'CERTS',
                                  textColor: c.textPrimary,
                                  labelColor: c.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── In-Progress Section ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
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
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'In Progress',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/etudiant/learn'),
                          child: const Text(
                            'See all',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.school_outlined,
                              color: c.textMuted,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No courses in progress yet.',
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 13,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/etudiant/learn',
                                (r) => false,
                              ),
                              child: const Text(
                                'Browse courses →',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

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
                onTap: () async {
                  debugPrint('🚪 Logout tapped');
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) context.read<UserProvider>().clearUser();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    debugPrint('❌ Logout error: $e');
                  }
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

// ── Helper Widgets ──
class _ProgressCourseItem extends StatelessWidget {
  final String title;
  final double progress;
  final int lessonsCurrent, lessonsTotal;
  const _ProgressCourseItem({
    required this.title,
    required this.progress,
    required this.lessonsCurrent,
    required this.lessonsTotal,
  });
  @override
  Widget build(BuildContext context) {
    /* ... unchanged ... */
    return Container();
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color textColor, labelColor;
  const _StatItem({
    required this.value,
    required this.label,
    required this.textColor,
    required this.labelColor,
  });
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    ],
  );
}
