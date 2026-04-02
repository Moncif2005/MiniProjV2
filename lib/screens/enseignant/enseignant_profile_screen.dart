import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/profile_menu_item.dart';

class EnseignantProfileScreen extends StatefulWidget {
  const EnseignantProfileScreen({super.key});

  @override
  State<EnseignantProfileScreen> createState() =>
      _EnseignantProfileScreenState();
}

class _EnseignantProfileScreenState
    extends State<EnseignantProfileScreen> {
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
                  '/enseignant/home',
                  (r) => false);
              break;
            case 1:
              Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/enseignant/courses',
                  (r) => false);
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/offers', (r) => false);
              break;
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ── Header ──
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
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
                    onTap: () => Navigator.pushNamed(
                        context, '/edit-profile'),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 1.24,
                              color: c.border),
                          borderRadius:
                              BorderRadius.circular(14),
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
                    side: BorderSide(
                        width: 1.24, color: c.border),
                    borderRadius:
                        BorderRadius.circular(40),
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
                          colors:
                              AppColors.gradientBlue,
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          24, 0, 24, 24),
                      child: Column(
                        children: [
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
                                  padding:
                                      const EdgeInsets.all(
                                          4),
                                  child: ClipOval(
                                    child: Container(
                                      color: AppColors
                                          .primaryLight,
                                      child: Center(
                                        child: Text(
                                          user.initials,
                                          style:
                                              const TextStyle(
                                            color: AppColors
                                                .primary,
                                            fontSize: 28,
                                            fontFamily:
                                                'Inter',
                                            fontWeight:
                                                FontWeight
                                                    .w700,
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
                                          width: 2),
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

                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : 'Alex Thompson',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight:
                                        FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'UI/UX Designer & Frontend Dev',
                                  style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight:
                                        FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // ── Enseignant Badge ──
                                Container(
                                  padding: const EdgeInsets
                                      .symmetric(
                                          horizontal: 12,
                                          vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors
                                        .greenLight,
                                    borderRadius:
                                        BorderRadius.circular(
                                            100),
                                  ),
                                  child: const Text(
                                    'Enseignant',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
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
                                  margin: const EdgeInsets
                                      .symmetric(
                                          horizontal: 16),
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
                                  margin: const EdgeInsets
                                      .symmetric(
                                          horizontal: 16),
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

              // ── My Courses section ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.24, color: c.border),
                    borderRadius:
                        BorderRadius.circular(24),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Courses',
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 18,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, '/create-course'),
                          child: const Text(
                            '+ Create New',
                            style: TextStyle(
                              color: AppColors.green,
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _CourseItem(
                      title: 'Arabic for Professionals',
                      students: '45 students',
                      rating: '⭐ 4.9',
                      status: 'active',
                    ),
                    const SizedBox(height: 12),
                    _CourseItem(
                      title: 'French Advanced',
                      students: '32 students',
                      rating: '⭐ 4.8',
                      status: 'active',
                    ),
                    const SizedBox(height: 12),
                    _CourseItem(
                      title: 'JavaScript Basics',
                      students: '50 students',
                      rating: '⭐ 4.7',
                      status: 'active',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Time Allocation ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                        width: 1.24, color: c.border),
                    borderRadius:
                        BorderRadius.circular(24),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time Allocation',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ── Pie chart placeholder ──
                    Container(
                      height: 180,
                      alignment: Alignment.center,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 160,
                            height: 160,
                            child:
                                CircularProgressIndicator(
                              value: 0.45,
                              strokeWidth: 16,
                              backgroundColor:
                                  const Color(0xFF10B981),
                              color: AppColors.primary,
                            ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '45%',
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 24,
                                  fontFamily: 'Inter',
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Teaching',
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
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          color: AppColors.primary,
                          label: 'Learning',
                          textColor: c.textSecondary,
                        ),
                        const SizedBox(width: 24),
                        _LegendItem(
                          color: const Color(0xFF10B981),
                          label: 'Working',
                          textColor: c.textSecondary,
                        ),
                        const SizedBox(width: 24),
                        _LegendItem(
                          color: const Color(0xFFF59E0B),
                          label: 'Networking',
                          textColor: c.textSecondary,
                        ),
                      ],
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
                onTap: () => Navigator.pushNamed(
                    context, '/certificates'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                iconBg: context.colors.iconBg,
                iconColor: context.colors.textSecondary,
                title: 'Parameters',
                onTap: () => Navigator.pushNamed(
                    context, '/settings'),
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
                  Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/signup',
                      (route) => false);
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

// ── Course Item ──
class _CourseItem extends StatelessWidget {
  final String title;
  final String students;
  final String rating;
  final String status;

  const _CourseItem({
    required this.title,
    required this.students,
    required this.rating,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.bg,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(students,
                        style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter')),
                    const SizedBox(width: 16),
                    Text(rating,
                        style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter')),
                    const SizedBox(width: 16),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius:
                            BorderRadius.circular(100),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                    size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Legend Item ──
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Stat Item ──
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
