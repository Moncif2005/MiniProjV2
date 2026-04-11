import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../widgets/applied_job_card.dart';

// ✅ ملاحظة مهمة: لا نعرّف JobStatus هنا - نستخدم الموجود في applied_job_card.dart

// ✅ دالة مساعدة لتحويل النص إلى JobStatus (تستخدم النوع المستورد)
JobStatus _stringToJobStatus(String? status) {
  switch (status?.toLowerCase()) {
    case 'reviewing':
      return JobStatus.reviewing;
    case 'interview':
      return JobStatus.interview;
    case 'accepted':
      return JobStatus.accepted;
    case 'rejected':
      return JobStatus.rejected;
    case 'withdrawn':
      return JobStatus.withdrawn;
    default:
      return JobStatus.pending;
  }
}

// ✅ دالة مساعدة لتنسيق الوقت
String _timeAgo(Timestamp? timestamp) {
  if (timestamp == null) return 'Recently';
  final diff = DateTime.now().difference(timestamp.toDate());
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
  if (diff.inDays > 0) return '${diff.inDays}d ago';
  if (diff.inHours > 0) return '${diff.inHours}h ago';
  return 'Just now';
}

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  int _selectedFilter = 0;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // ✅ فلاتر الديناميكية
  final _filters = [
    {'label': 'All', 'status': null},
    {'label': 'Pending', 'status': 'pending'},
    {'label': 'Reviewing', 'status': 'reviewing'},
    {'label': 'Interview', 'status': 'interview'},
    {'label': 'Accepted', 'status': 'accepted'},
    {'label': 'Rejected', 'status': 'rejected'},
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final userId = _auth.currentUser?.uid;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: c.bg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: c.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Applications',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    // ✅ العداد الديناميكي
                    StreamBuilder<QuerySnapshot>(
                      stream: userId != null
                          ? _firestore
                                .collection('applications')
                                .where('applicantId', isEqualTo: userId)
                                .snapshots()
                          : const Stream<
                              QuerySnapshot
                            >.empty(), // ✅ تصحيح النوع هنا
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return Text(
                            '0 applications sent',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 12,
                              fontFamily: 'Inter',
                            ),
                          );
                        final count = snapshot.data!.docs.length;
                        return Text(
                          '$count applications sent',
                          style: TextStyle(
                            color: c.textSecondary,
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Overview Card ──
          userId == null
              ? const SizedBox.shrink()
              : StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('applications')
                      .where('applicantId', isEqualTo: userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        margin: const EdgeInsets.all(24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.gradientBlue,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Text(
                          "Overview",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      );
                    }
                    final apps = snapshot.data!.docs;
                    final reviewing = apps
                        .where((d) => d['status'] == 'reviewing')
                        .length;
                    final interview = apps
                        .where((d) => d['status'] == 'interview')
                        .length;
                    final accepted = apps
                        .where((d) => d['status'] == 'accepted')
                        .length;

                    return Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: AppColors.gradientBlue,
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Overview",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              _OverviewStat(
                                value: '$reviewing',
                                label: 'Reviewing',
                              ),
                              const SizedBox(width: 32),
                              _OverviewStat(
                                value: '$interview',
                                label: 'Interviews',
                              ),
                              const SizedBox(width: 32),
                              _OverviewStat(
                                value: '$accepted',
                                label: 'Accepted',
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // ── Filter Chips ──
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedFilter == index;
                final filter = _filters[index];
                final statusFilter = filter['status'] as String?;

                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? c.textPrimary : c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? c.textPrimary : c.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            color: isSelected ? c.surface : c.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // ✅ عداد الفلتر: فلترة محلية لتجنب مشاكل فهرسة Firestore
                        StreamBuilder<QuerySnapshot>(
                          stream: userId != null
                              ? _firestore
                                    .collection('applications')
                                    .where('applicantId', isEqualTo: userId)
                                    .snapshots()
                              : const Stream<
                                  QuerySnapshot
                                >.empty(), // ✅ تصحيح النوع هنا
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return _FilterBadge(
                                count: 0,
                                isSelected: isSelected,
                                c: c,
                              );
                            }
                            final allApps = snapshot.data!.docs;
                            // ✅ فلترة محلية حسب الحالة
                            final count = statusFilter == null
                                ? allApps.length
                                : allApps
                                      .where((d) => d['status'] == statusFilter)
                                      .length;
                            return _FilterBadge(
                              count: count,
                              isSelected: isSelected,
                              c: c,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── List of Applied Jobs ──
          Expanded(
            child: userId == null
                ? const Center(
                    child: Text('Please sign in to view applications'),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('applications')
                        .where('applicantId', isEqualTo: userId)
                        .orderBy('appliedAt', descending: true)
                        .snapshots(),
                    builder: (context, appsSnapshot) {
                      if (appsSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // ✅ معالجة أخطاء الفهرسة
                      if (appsSnapshot.hasError) {
                        debugPrint('❌ Firestore Error: ${appsSnapshot.error}');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                size: 48,
                                color: c.textMuted,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error loading applications',
                                style: TextStyle(color: c.textPrimary),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Check console for index setup link',
                                style: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!appsSnapshot.hasData ||
                          appsSnapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(c);
                      }

                      // ✅ فلترة محلية حسب التبويب المختار
                      final selectedStatus =
                          _filters[_selectedFilter]['status'] as String?;
                      var applications = appsSnapshot.data!.docs;

                      if (selectedStatus != null) {
                        applications = applications.where((d) {
                          final status = d['status'] as String?;
                          return status == selectedStatus;
                        }).toList();
                      }

                      if (applications.isEmpty) {
                        return Center(
                          child: Text(
                            'No applications with "${_filters[_selectedFilter]['label']}" status',
                            style: TextStyle(color: c.textMuted),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        itemCount: applications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final appDoc = applications[index];
                          final app = appDoc.data() as Map<String, dynamic>;
                          final appId = appDoc.id;

                          // ✅ جلب بيانات الوظيفة الأصلية
                          return FutureBuilder<DocumentSnapshot>(
                            future: _firestore
                                .collection('offers')
                                .doc(app['offerId'])
                                .get(),
                            builder: (context, offerSnap) {
                              // بيانات افتراضية في حال عدم وجود العرض
                              final title = app['offerTitle'] ?? 'Unknown Job';
                              final company =
                                  app['company'] ?? 'Unknown Company';
                              final location = app['location'] ?? 'Remote';
                              final jobType = app['jobType'] ?? 'Full-time';
                              final salary = app['salary'] ?? 'Negotiable';
                              final companyInitial =
                                  (company.isNotEmpty ? company[0] : 'U')
                                      .toUpperCase();
                              final companyBg = AppColors.primaryLight;
                              final companyColor = AppColors.primary;
                              final views = 0;

                              // إذا وُجد العرض، نستخدم بياناته
                              if (offerSnap.hasData && offerSnap.data!.exists) {
                                final offer = offerSnap.data!.data() as Map<String, dynamic>;
                                final recruiterId = offer['recruiterId'] as String?; // ✅ استخراج المعرف
                                
                                return _buildJobCard(
                                  c: c,
                                  title: offer['title'] ?? title,
                                  company: offer['company'] ?? company,
                                  companyInitial: offer['companyInitial'] ?? companyInitial,
                                  companyBg: Color(offer['companyBgColor'] ?? 4293848063),
                                  companyColor: Color(offer['companyColor'] ?? 4283322870),
                                  location: offer['location'] ?? location,
                                  jobType: offer['jobType'] ?? jobType,
                                  salary: offer['salary'] ?? salary,
                                  appliedAgo: _timeAgo(app['appliedAt']),
                                  views: offer['views'] ?? views,
                                  status: _stringToJobStatus(app['status']),
                                  statusMessage: app['statusMessage'],
                                  appId: appId,
                                  offerId: app['offerId'],
                                  recruiterId: recruiterId,  // ✅ تمرير المعرف للدالة
                                  onWithdraw: () => _withdrawApplication(context, appId),
                                );
                              }
                              
                              // الحالة الثانية: إذا حُذف العرض
                              return _buildJobCard(
                                c: c,
                                title: title,
                                company: company,
                                companyInitial: companyInitial,
                                companyBg: companyBg,
                                companyColor: companyColor,
                                location: location,
                                jobType: jobType,
                                salary: salary,
                                appliedAgo: _timeAgo(app['appliedAt']),
                                views: views,
                                status: _stringToJobStatus(app['status']),
                                statusMessage: app['statusMessage'],
                                appId: appId,
                                offerId: null,
                                recruiterId: app['recruiterId'] as String?, // ✅ محاولة جلبه من بيانات التطبيق
                                onWithdraw: () => _withdrawApplication(context, appId),
                              );                            },
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ✅ دالة مساعدة لبناء البطاقة (تجنب تكرار الكود)
  // ✅ دالة مساعدة لبناء البطاقة (محدثة مع دعم النقر على الأفاتار)
  Widget _buildJobCard({
    required ThemeColors c,
    required String title,
    required String company,
    required String companyInitial,
    required Color companyBg,
    required Color companyColor,
    required String location,
    required String jobType,
    required String salary,
    required String appliedAgo,
    required int views,
    required JobStatus status,
    required String? statusMessage,
    required String appId,
    required String? offerId,
    required String? recruiterId,  // ✅ جديد
    required VoidCallback onWithdraw,
  }) {
    return AppliedJobCard(
      title: title,
      company: company,
      companyInitial: companyInitial,
      companyBg: companyBg,
      companyColor: companyColor,
      location: location,
      jobType: jobType,
      salary: salary,
      appliedAgo: appliedAgo,
      views: views,
      status: status,
      statusMessage: statusMessage,
      onViewOffer: offerId != null 
          ? () => Navigator.pushNamed(context, '/offers', arguments: {'offerId': offerId})
          : null,
      applicationId: appId,
      onWithdraw: onWithdraw,
      recruiterId: recruiterId,  // ✅ تمرير معرف المسؤول
      onAvatarTap: recruiterId != null ? () {  // ✅ ربط النقر بالبروفايل العام
        Navigator.pushNamed(context, '/public/profile', arguments: {
          'userId': recruiterId,
          'role': 'recruteur',
        });
      } : null,
    );
  }
  // ✅ دالة سحب التقديم
  Future<void> _withdrawApplication(BuildContext context, String appId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Withdraw Application?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Withdraw',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        await FirebaseFirestore.instance
            .collection('applications')
            .doc(appId)
            .delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application withdrawn ✓'),
              backgroundColor: AppColors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Withdraw error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      }
    }
  }

  // ── Empty State Widget ──
  Widget _buildEmptyState(ThemeColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: AppColors.primary,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No applications yet',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 18,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't applied to any jobs yet.",
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/offers',
                (route) => false,
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Browse Jobs',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

// ── Helper: Badge الفلتر ──
class _FilterBadge extends StatelessWidget {
  final int count;
  final bool isSelected;
  final ThemeColors c;
  const _FilterBadge({
    required this.count,
    required this.isSelected,
    required this.c,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
    decoration: BoxDecoration(
      color: isSelected ? Colors.white.withOpacity(0.20) : c.border,
      borderRadius: BorderRadius.circular(100),
    ),
    child: Text(
      '$count',
      style: TextStyle(
        color: isSelected ? Colors.white : c.textSecondary,
        fontSize: 10,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

// ── Helper: Overview Stat ──
class _OverviewStat extends StatelessWidget {
  final String value;
  final String label;
  const _OverviewStat({required this.value, required this.label});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
      ),
      Opacity(
        opacity: 0.8,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
      ),
    ],
  );
}
