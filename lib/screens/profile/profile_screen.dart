import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
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
                '/home',
                (route) => false,
              );
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/learn',
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
                  Container(
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
                                  // ── Show initials if no photo ──
                                  child: ClipOval(
                                    child: Container(
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
                                  // ── Real name from provider ──
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
                                  'UI/UX Designer & Frontend Dev',
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
                                  child: const Text(
                                    'Student',
                                    style: TextStyle(
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
                                  value: '12',
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
                                  value: '4.9k',
                                  label: 'POINTS',
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
                                  value: '8',
                                  label: 'PROJECTS',
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

              // ── Menu Items ──
              ProfileMenuItem(
                icon: Icons.workspace_premium_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'My Certificates',
                badge: '4',
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
                badge: '12',
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
                  // ── Clear user on logout ──
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  await authService.signOut();
                  context.read<AuthService>().signOut();
                  context.read<UserProvider>().clearUser();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signup',
                      (route) => false,
                    );
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color textColor;
  final Color labelColor;

  const _StatItem({
    required this.value,
    required this.label,
    required this.textColor,
    required this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
}
