import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../services/learning_history_service.dart';

import '../../theme/app_colors.dart';

import '../../providers/user_provider.dart';

import '../../widgets/profile_menu_item.dart';

import '../shared/course_details_screen.dart';

import 'learn_etudiant_screen.dart';
import '../../l10n/app_localizations.dart';

class ProfileEtudiantScreen extends StatefulWidget {
  const ProfileEtudiantScreen({super.key});

  @override
  State<ProfileEtudiantScreen> createState() => _ProfileEtudiantScreenState();
}

class _ProfileEtudiantScreenState extends State<ProfileEtudiantScreen> {
  // متغيرات لتخزين الإحصائيات الحقيقية
  int _completedCoursesCount = 0;
  int _certificatesCount = 0;
  EnrollmentModel? _currentProgress;
  bool _statsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_statsLoaded) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final uid = context.read<UserProvider>().uid;
    if (uid == null || uid.isEmpty) return;

    setState(() => _statsLoaded = true);

    try {
      // جلب سجلات التسجيل (Enrollments)
      final enrollments = await LearningHistoryService().fetchEnrollments(uid);
      
      debugPrint('📊 Total Enrollments found: ${enrollments.length}');

      // 1. حساب الكورسات المكتملة
      // نعتمد على حقل isCompleted الموجود في موديل التسجيل
      final completed = enrollments.where((e) => e.isCompleted).length;
      
      // 2. حساب الشهادات
      // حالياً نعتبر أن كل كورس مكتمل يمنح شهادة. 
      // لاحقاً يمكن ربطها بخدمة الشهادات الفعلية.
      final certs = completed; 

      // 3. العثور على كورس قيد التقدم
      // الشرط: لم يكتمل AND نسبة التقدم أكبر من 0
      final inProgress = enrollments
          .where((e) => !e.isCompleted && e.progressPercent > 0)
          .toList();

      if (mounted) {
        setState(() {
          _completedCoursesCount = completed;
          _certificatesCount = certs;
          _currentProgress = inProgress.isNotEmpty ? inProgress.first : null;
          
          debugPrint('✅ Stats Updated: Completed=$_completedCoursesCount, Certs=$_certificatesCount, InProgress=${_currentProgress?.courseTitle}');
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading profile stats: $e');
    }
  }

  Widget _buildInitials(ThemeColors c, UserProvider user) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context).myProfile,
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
                    BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1),
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
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: c.surface),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipOval(
                                    child: (user.avatarPath != null && user.avatarPath!.isNotEmpty)
                                        ? (user.avatarPath!.startsWith('http')
                                            ? Image.network(user.avatarPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitials(c, user))
                                            : Image.file(File(user.avatarPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildInitials(c, user)))
                                        : _buildInitials(c, user),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle, border: Border.all(color: c.surface, width: 2)),
                                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // ── Name + Bio (✅ تم تغيير الإيميل إلى Bio) ──
                          Transform.translate(
                            offset: const Offset(0, -40),
                            child: Column(
                              children: [
                                Text(
                                  user.name.isNotEmpty ? user.name : 'Student',
                                  style: TextStyle(color: c.textPrimary, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 8),
                                
                                // ✅ عرض الـ Bio بدلاً من الإيميل
                                if (user.bio != null && user.bio.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      user.bio,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter', height: 1.4),
                                    ),
                                  )
                                else
                                  Text(
                                    'No bio added yet.',
                                    style: TextStyle(color: c.textMuted, fontSize: 14, fontFamily: 'Inter', fontStyle: FontStyle.italic),
                                  ),

                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(100)),
                                  child: Text(
                                    'Student',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // ── Real Stats ──
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _StatItem(value: '$_completedCoursesCount', label: 'COMPLETED', textColor: c.textPrimary, labelColor: c.textMuted),
                                Container(width: 1, height: 32, color: c.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
                                _StatItem(value: '$_certificatesCount', label: 'CERTIFICATES', textColor: c.textPrimary, labelColor: c.textMuted),
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

              // ── In-Progress Section (Real Data) ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(side: BorderSide(width: 1.24, color: c.border), borderRadius: BorderRadius.circular(24)),
                  shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppLocalizations.of(context).inProgress, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/etudiant/learn'),
                          child: Text(AppLocalizations.of(context).seeAll, style: TextStyle(color: AppColors.primary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (_currentProgress != null) ...[
                      GestureDetector(
                        onTap: () {
                           Navigator.push(
                             context,
                             MaterialPageRoute(
                               builder: (_) => CourseDetailsScreen(courseId: _currentProgress!.courseId),
                             ),
                           );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(12)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_currentProgress!.courseTitle, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: LinearProgressIndicator(
                                  value: _currentProgress!.progressPercent / 100,
                                  minHeight: 6,
                                  backgroundColor: c.border,
                                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('${_currentProgress!.progressPercent.toInt()}% ${AppLocalizations.of(context).complete}', style: TextStyle(color: c.textMuted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Column(
                            children: [
                              Icon(Icons.school_outlined, color: c.textMuted, size: 40),
                              const SizedBox(height: 8),
                              Text(AppLocalizations.of(context).noCoursesInProgress, style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter')),
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LearnEtudiantScreen(showBackButton: true),
                                  ),
                                ),
                                child: Text(AppLocalizations.of(context).browseCourses, style: TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Menu Items ──
              ProfileMenuItem(
                icon: Icons.workspace_premium_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: AppLocalizations.of(context).myPortfolio,
                onTap: () => Navigator.pushNamed(context, '/portfolio'),
              ),
              const SizedBox(height: 8),
              
              // ✅ 2. تم إخفاء Learning History مؤقتاً
              /*
              ProfileMenuItem(
                icon: Icons.history_rounded,
                iconBg: c.iconBg,
                iconColor: c.textSecondary,
                title: AppLocalizations.of(context).learningHistory,
                onTap: () => Navigator.pushNamed(context, '/learning-history'),
              ),
              const SizedBox(height: 8),
              */

              ProfileMenuItem(
                icon: Icons.work_outline_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: AppLocalizations.of(context).appliedJobs,
                onTap: () => Navigator.pushNamed(context, '/applied-jobs'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                iconBg: c.iconBg,
                iconColor: c.textSecondary,
                title: AppLocalizations.of(context).parameters,
                onTap: () => Navigator.pushNamed(context, '/settings'),
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.logout_rounded,
                iconBg: AppColors.redLight,
                iconColor: AppColors.red,
                title: AppLocalizations.of(context).logOut,
                isDestructive: true,
                onTap: () async {
                  debugPrint('🚪 Logout tapped');
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (mounted) context.read<UserProvider>().clearUser();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color textColor, labelColor;
  const _StatItem({required this.value, required this.label, required this.textColor, required this.labelColor});
  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: TextStyle(color: textColor, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: labelColor, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 1)),
        ],
      );
}