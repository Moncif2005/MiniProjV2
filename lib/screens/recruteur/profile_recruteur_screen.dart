import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/screens/recruteur/recruiter_applicants_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/profile_menu_item.dart';
import '../../services/offers_service.dart';

class ProfileRecruteurScreen extends StatefulWidget {
  const ProfileRecruteurScreen({super.key});
  @override
  State<ProfileRecruteurScreen> createState() => _ProfileRecruteurScreenState();
}

class _ProfileRecruteurScreenState extends State<ProfileRecruteurScreen> {
  // ✅ أضف هذه الدالة داخل كلاس _ProfileRecruteurScreenState
  Stream<Map<String, dynamic>> _buildStatsStream(String recruiterId) {
    return FirebaseFirestore.instance
        .collection('offers')
        .where('recruiterId', isEqualTo: recruiterId)
        .snapshots()
        .asyncMap((snapshot) async {
          int jobsPosted = 0, totalApplicants = 0, hiredCount = 0;
          final offerIds = snapshot.docs.map((d) => d.id).toList();

          for (var doc in snapshot.docs) {
            if (doc['isActive'] == true) jobsPosted++;
            totalApplicants += (doc['applicationsCount'] as num?)?.toInt() ?? 0;
          }

          if (offerIds.isNotEmpty) {
            final hired = await FirebaseFirestore.instance
                .collection('applications')
                .where('offerId', whereIn: offerIds)
                .where('status', isEqualTo: 'accepted')
                .count()
                .get();
            hiredCount = hired.count ?? 0;
          }

          return {
            'jobsPosted': jobsPosted,
            'totalApplicants': totalApplicants,
            'hiredCount': hiredCount,
          };
        });
  }

  int _currentNavIndex = 3;
  Map<String, dynamic> _stats = {
    'jobsPosted': 0,
    'totalApplicants': 0,
    'hiredCount': 0,
  };
  bool _statsLoading = true;
  final _offersService = OffersService();

  // ✅ تحميل الإحصائيات عند فتح الشاشة
  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final stats = await _offersService.getRecruiterStats(uid);
      if (mounted) {
        setState(() {
          _stats = stats;
          _statsLoading = false;
        });
      }
    }
  }

  // ✅ إعادة تحميل الإحصائيات عند العودة من شاشة التعديل
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة التحميل إذا عدنا من EditProfileScreen
    if (ModalRoute.of(context)?.settings.name == '/edit-profile') {
      _loadStats();
    }
  }
// ✅ دالة ذكية لاستخراج الموقع من أفضل حقل متاح
String _getUserLocation(UserProvider user) {
  // نجرب عدة حقول محتملة للموقع
  if (user.phone?.isNotEmpty == true && user.phone!.contains(RegExp(r'[a-zA-Z]'))) {
    // إذا كان الهاتف يحتوي على نص، ربما هو موقع
    return user.phone!;
  }
  // يمكن إضافة حقول أخرى مستقبلاً مثل: user.location, user.address
  return '—'; // عرض شرطة إذا لم يوجد موقع
}
  // ── Helper: Build initials avatar ──
  Widget _buildInitials(ThemeColors c, UserProvider user) {
    return Container(
      color: AppColors.purpleLight,
      child: Center(
        child: Text(
          user.initials,
          style: const TextStyle(
            color: AppColors.purple,
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
      // bottomNavigationBar: BottomNavBar(
      //   currentIndex: _currentNavIndex,
      //   onTap: (index) {
      //     setState(() => _currentNavIndex = index);
      //     switch (index) {
      //       case 0:
      //         Navigator.pushNamed(context, '/recruteur/home');
      //         break;
      //       case 1:
      //         // ✅ "My Job Posts" → شاشة وظائف المسؤول فقط
      //         Navigator.pushNamed(context, '/recruteur/jobs');
      //         break;
      //       case 2:
      //         Navigator.pushNamed(context, '/offers');
      //         break;
      //     }
      //   },
      // ),
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
                          colors: AppColors.gradientPurple,
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
                                                        color: AppColors.purple,
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
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/edit-profile',
                                    ),
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.purple,
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
                                      : 'Your Company',
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.bio.isNotEmpty
                                      ? user.bio
                                      : 'HR Manager & Talent Acquisition',
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
                                    color: AppColors.purpleLight,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    user.roleLabel.isNotEmpty
                                        ? user.roleLabel
                                        : 'Recruteur',
                                    style: const TextStyle(
                                      color: AppColors.purple,
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ── Stats (ديناميكية من Firestore) ──
                          // ── Stats (لحظية عبر Stream) ──
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: StreamBuilder<Map<String, dynamic>>(
                              stream:
                                  FirebaseAuth.instance.currentUser?.uid != null
                                  ? _buildStatsStream(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    )
                                  : null,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    height: 32,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }
                                final stats =
                                    snapshot.data ??
                                    {
                                      'jobsPosted': 0,
                                      'totalApplicants': 0,
                                      'hiredCount': 0,
                                    };

                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _StatItem(
                                      value: '${stats['jobsPosted']}',
                                      label: 'JOBS',
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
                                      value: '${stats['totalApplicants']}',
                                      label: 'CANDIDATES',
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
                                      value: '${stats['hiredCount']}',
                                      label: 'HIRED',
                                      textColor: c.textPrimary,
                                      labelColor: c.textMuted,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
// ── Company Info (ديناميكي من الحقول الجديدة) ──
Container(
  width: double.infinity,
  padding: const EdgeInsets.all(20),
  decoration: ShapeDecoration(
    color: c.surface,
    shape: RoundedRectangleBorder(
      side: BorderSide(width: 1.24, color: c.border),
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Company Info', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          TextButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/edit-profile'),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppColors.purple),
          ),
        ],
      ),
      const SizedBox(height: 16),
      
      _InfoRow(c: c, icon: Icons.business_rounded, label: 'Company', value: user.name.isNotEmpty ? user.name : '—'),
      const SizedBox(height: 12),
_InfoRow(c: c, icon: Icons.location_on_outlined, label: 'Location', value: user.location.isNotEmpty ? user.location : '—'),
_InfoRow(c: c, icon: Icons.people_rounded, label: 'Company Size', value: user.companySize.isNotEmpty ? user.companySize : '—'),
_InfoRow(c: c, icon: Icons.language_rounded, label: 'Industry', value: user.industry.isNotEmpty ? user.industry : '—'),    ],
  ),
),
              const SizedBox(height: 16),

              // ── Menu Items ──
              ProfileMenuItem(
                icon: Icons.work_outline_rounded,
                iconBg: AppColors.purpleLight,
                iconColor: AppColors.purple,
                title: 'My Job Posts',
                badge: _statsLoading ? null : '${_stats['jobsPosted']}',
                onTap: () => Navigator.pushNamed(
                  context,
                  '/recruteur/jobs',
                ), // ✅ شاشة وظائف المسؤول
              ),
              const SizedBox(height: 8),
              ProfileMenuItem(
                icon: Icons.people_outline_rounded,
                iconBg: AppColors.primaryLight,
                iconColor: AppColors.primary,
                title: 'Candidates',
                badge: _statsLoading ? null : '${_stats['totalApplicants']}',
                onTap: () =>
                    Navigator.pushNamed(context, '/recruteur/candidates'),
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
class _InfoRow extends StatelessWidget {
  final ThemeColors c;
  final IconData icon;
  final String label, value;
  const _InfoRow({
    required this.c,
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.purpleLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.purple, size: 16),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 11,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    ],
  );
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
