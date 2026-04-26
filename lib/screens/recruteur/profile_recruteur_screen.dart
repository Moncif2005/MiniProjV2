import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../theme/app_colors.dart';

import '../../providers/user_provider.dart';

import '../../widgets/profile_menu_item.dart';

import '../../services/offers_service.dart';
import '../../l10n/app_localizations.dart';

class ProfileRecruteurScreen extends StatefulWidget {
  const ProfileRecruteurScreen({super.key});
  @override
  State<ProfileRecruteurScreen> createState() => _ProfileRecruteurScreenState();
}

class _ProfileRecruteurScreenState extends State<ProfileRecruteurScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _offersService = OffersService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            .where('offerId', whereIn: offerIds.take(10).toList())
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

  Widget _buildInitials(ThemeColors c, UserProvider user) => Container(
        color: AppColors.purpleLight,
        child: Center(
          child: Text(user.initials,
              style: const TextStyle(
                  color: AppColors.purple,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final user = context.watch<UserProvider>();
    final recruiterId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(
              child: Column(children: [
                // ── Top Bar ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(AppLocalizations.of(context).myProfile,
                          style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: () =>
                            Navigator.pushNamed(context, '/edit-profile'),
                        child: Container(
                          width: 38, height: 38,
                          decoration: ShapeDecoration(
                            color: c.surface,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 1.24, color: c.border),
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Icon(Icons.edit_outlined,
                              color: c.textSecondary, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Profile Card ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: c.surface,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 1.24, color: c.border),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      shadows: const [
                        BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 8,
                            offset: Offset(0, 4))
                      ],
                    ),
                    child: Column(children: [
                      Container(
                        height: 80,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.gradientPurple,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(children: [
                          // Avatar
                          Transform.translate(
                            offset: const Offset(0, -44),
                            child: Stack(children: [
                              Container(
                                width: 88, height: 88,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: c.surface,
                                    border: Border.all(
                                        color: c.surface, width: 4)),
                                child: ClipOval(
                                  child: (user.avatarPath != null &&
                                          user.avatarPath!.isNotEmpty)
                                      ? (user.avatarPath!.startsWith('http')
                                          ? Image.network(user.avatarPath!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildInitials(c, user))
                                          : Image.file(
                                              File(user.avatarPath!),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  _buildInitials(c, user)))
                                      : _buildInitials(c, user),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () => Navigator.pushNamed(
                                      context, '/edit-profile'),
                                  child: Container(
                                    width: 28, height: 28,
                                    decoration: BoxDecoration(
                                        color: AppColors.purple,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: c.surface, width: 2)),
                                    child: const Icon(Icons.edit_rounded,
                                        color: Colors.white, size: 13),
                                  ),
                                ),
                              ),
                            ]),
                          ),

                          // Name & Role
                          Transform.translate(
                            offset: const Offset(0, -36),
                            child: Column(children: [
                              Text(
                                  user.name.isNotEmpty
                                      ? user.name
                                      : 'Your Company',
                                  style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 20,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(
                                  user.bio.isNotEmpty
                                      ? user.bio
                                      : 'HR Manager & Talent Acquisition',
                                  style: TextStyle(
                                      color: c.textSecondary,
                                      fontSize: 13,
                                      fontFamily: 'Inter'),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                    color: AppColors.purpleLight,
                                    borderRadius: BorderRadius.circular(100)),
                                child: Text(
                                    user.roleLabel.isNotEmpty
                                        ? user.roleLabel
                                        : 'Recruteur',
                                    style: const TextStyle(
                                        color: AppColors.purple,
                                        fontSize: 12,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w700)),
                              ),
                            ]),
                          ),

                          // Stats Row
                          Transform.translate(
                            offset: const Offset(0, -20),
                            child: recruiterId == null
                                ? const SizedBox.shrink()
                                : StreamBuilder<Map<String, dynamic>>(
                                    stream: _buildStatsStream(recruiterId),
                                    builder: (context, snap) {
                                      final stats = snap.data ??
                                          {
                                            'jobsPosted': 0,
                                            'totalApplicants': 0,
                                            'hiredCount': 0
                                          };
                                      return Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          _StatItem(
                                              value: '${stats['jobsPosted']}',
                                              label: 'JOBS',
                                              textColor: c.textPrimary,
                                              labelColor: c.textMuted),
                                          _VDivider(c: c),
                                          _StatItem(
                                              value:
                                                  '${stats['totalApplicants']}',
                                              label: 'CANDIDATES',
                                              textColor: c.textPrimary,
                                              labelColor: c.textMuted),
                                          _VDivider(c: c),
                                          _StatItem(
                                              value: '${stats['hiredCount']}',
                                              label: 'HIRED',
                                              textColor: c.textPrimary,
                                              labelColor: c.textMuted),
                                        ],
                                      );
                                    },
                                  ),
                          ),
                        ]),
                      ),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Tab Bar ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: c.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: c.border, width: 1.24),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      dividerColor: Colors.transparent,
                      indicator: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(11),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: c.textSecondary,
                      labelStyle: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700),
                      unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w500),
                      tabs: [
                        Tab(text: AppLocalizations.of(context).overview),
                        Tab(text: AppLocalizations.of(context).dashboard),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _OverviewTab(user: user, c: c),
              recruiterId == null
                  ? Center(child: Text(AppLocalizations.of(context).pleaseSignIn))
                  : _DashboardTab(recruiterId: recruiterId, c: c),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 1 — Overview
// ─────────────────────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final UserProvider user;
  final ThemeColors c;
  const _OverviewTab({required this.user, required this.c});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Company Info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: ShapeDecoration(
            color: c.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: c.border),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(AppLocalizations.of(context).companyInfo,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700)),
              TextButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, '/edit-profile'),
                icon: const Icon(Icons.edit_rounded, size: 14),
                label: Text(AppLocalizations.of(context).edit,
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.purple,
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              ),
            ]),
            const SizedBox(height: 14),
            _InfoRow(c: c, icon: Icons.business_rounded, label: 'Company',
                value: user.name.isNotEmpty ? user.name : '—'),
            const SizedBox(height: 10),
            _InfoRow(c: c, icon: Icons.location_on_outlined, label: 'Location',
                value: user.location.isNotEmpty ? user.location : '—'),
            const SizedBox(height: 10),
            _InfoRow(c: c, icon: Icons.people_rounded, label: 'Company Size',
                value: user.companySize.isNotEmpty ? user.companySize : '—'),
            const SizedBox(height: 10),
            _InfoRow(c: c, icon: Icons.language_rounded, label: 'Industry',
                value: user.industry.isNotEmpty ? user.industry : '—'),
          ]),
        ),
        const SizedBox(height: 16),

        // Menu Items
        ProfileMenuItem(
          icon: Icons.work_outline_rounded,
          iconBg: AppColors.purpleLight,
          iconColor: AppColors.purple,
          title: AppLocalizations.of(context).myJobPosts,
          onTap: () => Navigator.pushNamed(context, '/recruteur/jobs'),
        ),
        const SizedBox(height: 8),
        ProfileMenuItem(
          icon: Icons.people_outline_rounded,
          iconBg: AppColors.primaryLight,
          iconColor: AppColors.primary,
          title: AppLocalizations.of(context).candidates,
          onTap: () => Navigator.pushNamed(context, '/recruteur/candidates'),
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
            try {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                context.read<UserProvider>().clearUser();
                Navigator.pushNamedAndRemoveUntil(
                    context, '/home', (route) => false);
              }
            } catch (e) {
              debugPrint('Logout error: $e');
            }
          },
        ),
        const SizedBox(height: 32),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// TAB 2 — Dashboard
// ─────────────────────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  final String recruiterId;
  final ThemeColors c;
  const _DashboardTab({required this.recruiterId, required this.c});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: OffersService().getOffersByRecruiter(recruiterId),
      builder: (context, offersSnap) {
        if (offersSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final offers = offersSnap.data ?? [];
        final offerIds = offers.map((o) => o['id'] as String).toList();

        return StreamBuilder<QuerySnapshot>(
          stream: offerIds.isEmpty
              ? const Stream.empty()
              : FirebaseFirestore.instance
                  .collection('applications')
                  .where('offerId', whereIn: offerIds.take(10).toList())
                  .snapshots(),
          builder: (context, appsSnap) {
            final apps = appsSnap.data?.docs ?? [];

            final totalJobs = offers.length;
            final activeJobs = offers.where((o) => o['isActive'] == true).length;
            final closedJobs = totalJobs - activeJobs;
            final totalApplicants = offers.fold<int>(
                0, (s, o) => s + ((o['applicationsCount'] as num?)?.toInt() ?? 0));
            final totalViews = offers.fold<int>(
                0, (s, o) => s + ((o['views'] as num?)?.toInt() ?? 0));
            final conversionRate = totalApplicants > 0 && totalViews > 0
                ? ((totalApplicants / totalViews) * 100).toStringAsFixed(1)
                : '0.0';

            int pending = 0, reviewing = 0, interview = 0, hired = 0, rejected = 0;
            for (final a in apps) {
              final status = (a.data() as Map)['status'] ?? '';
              if (status == 'pending') pending++;
              else if (status == 'reviewing') reviewing++;
              else if (status == 'interview') interview++;
              else if (status == 'accepted') hired++;
              else if (status == 'rejected') rejected++;
            }

            final topJobs = [...offers]
              ..sort((a, b) =>
                  ((b['applicationsCount'] as num?)?.toInt() ?? 0)
                      .compareTo((a['applicationsCount'] as num?)?.toInt() ?? 0));

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Hero Banner
                _HeroBanner(totalJobs: totalJobs, activeJobs: activeJobs,
                    totalApplicants: totalApplicants, hired: hired),
                const SizedBox(height: 20),

                // Quick Stats
                _Label(c: c, text: 'Quick Stats'),
                const SizedBox(height: 10),
                Row(children: [
                  _QuickStat(c: c, label: AppLocalizations.of(context).totalViews, value: '$totalViews',
                      icon: Icons.visibility_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  _QuickStat(c: c, label: AppLocalizations.of(context).conversion, value: '$conversionRate%',
                      icon: Icons.trending_up_rounded, color: AppColors.green),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  _QuickStat(c: c, label: AppLocalizations.of(context).activeJobs, value: '$activeJobs',
                      icon: Icons.work_rounded, color: AppColors.purple),
                  const SizedBox(width: 10),
                  _QuickStat(c: c, label: AppLocalizations.of(context).closedJobs, value: '$closedJobs',
                      icon: Icons.lock_outline_rounded, color: Colors.orange),
                ]),
                const SizedBox(height: 20),

                // Pipeline
                _Label(c: c, text: 'Recruitment Pipeline'),
                const SizedBox(height: 10),
                _PipelineCard(c: c, pending: pending, reviewing: reviewing,
                    interview: interview, hired: hired, rejected: rejected,
                    total: apps.length),
                const SizedBox(height: 20),

                // Top Jobs
                _Label(c: c, text: AppLocalizations.of(context).topJobs),
                const SizedBox(height: 10),
                if (topJobs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text(AppLocalizations.of(context).postJobsAnalytics,
                        style: TextStyle(color: c.textMuted, fontFamily: 'Inter'))),
                  )
                else
                  ...topJobs.take(5).toList().asMap().entries.map((e) {
                    final job = e.value;
                    final maxApps = (topJobs.first['applicationsCount'] as num?)?.toInt() ?? 1;
                    final jobApps = (job['applicationsCount'] as num?)?.toInt() ?? 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _TopJobBar(c: c, rank: e.key + 1, job: job,
                          barPercent: maxApps > 0 ? jobApps / maxApps : 0.0,
                          applicantCount: jobApps),
                    );
                  }),
                const SizedBox(height: 20),

                // Recent Applications
                _Label(c: c, text: AppLocalizations.of(context).recentApplications),
                const SizedBox(height: 10),
                _RecentApps(c: c,
                    apps: apps.take(5)
                        .map((d) => d.data() as Map<String, dynamic>)
                        .toList()),
                const SizedBox(height: 32),
              ]),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Widgets
// ─────────────────────────────────────────────────────────────

class _Label extends StatelessWidget {
  final ThemeColors c;
  final String text;
  const _Label({required this.c, required this.text});
  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(color: c.textPrimary, fontSize: 16,
          fontFamily: 'Inter', fontWeight: FontWeight.w700));
}

class _HeroBanner extends StatelessWidget {
  final int totalJobs, activeJobs, totalApplicants, hired;
  const _HeroBanner({required this.totalJobs, required this.activeJobs,
      required this.totalApplicants, required this.hired});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: AppColors.gradientPurple),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x33AD46FF), blurRadius: 18,
              offset: Offset(0, 10), spreadRadius: -4)
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(AppLocalizations.of(context).recruitmentOverview,
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(AppLocalizations.of(context).liveAnalytics,
                style: const TextStyle(color: Color(0xFFEFD9FD), fontSize: 12,
                    fontFamily: 'Inter')),
          ]),
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.dashboard_rounded, color: Colors.white, size: 20),
          ),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          _HS(label: 'Total\nJobs', value: '$totalJobs'),
          _HVD(), _HS(label: 'Active', value: '$activeJobs'),
          _HVD(), _HS(label: AppLocalizations.of(context).navApplicants, value: '$totalApplicants'),
          _HVD(), _HS(label: AppLocalizations.of(context).hired, value: '$hired'),
        ]),
      ]),
    );
  }
}

class _HS extends StatelessWidget {
  final String label, value;
  const _HS({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Column(children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 22,
            fontFamily: 'Inter', fontWeight: FontWeight.w800)),
        const SizedBox(height: 3),
        Text(label, style: const TextStyle(color: Color(0xFFEFD9FD),
            fontSize: 10, fontFamily: 'Inter'), textAlign: TextAlign.center),
      ]));
}

class _HVD extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 36,
      color: Colors.white.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 4));
}

class _QuickStat extends StatelessWidget {
  final ThemeColors c;
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStat({required this.c, required this.label, required this.value,
      required this.icon, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(children: [
          Container(width: 38, height: 38,
              decoration: BoxDecoration(color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11)),
              child: Icon(icon, color: color, size: 18)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: TextStyle(color: c.textPrimary, fontSize: 18,
                fontFamily: 'Inter', fontWeight: FontWeight.w700)),
            Text(label, style: TextStyle(color: c.textSecondary, fontSize: 10,
                fontFamily: 'Inter')),
          ]),
        ]),
      ));
}

class _PipelineCard extends StatelessWidget {
  final ThemeColors c;
  final int pending, reviewing, interview, hired, rejected, total;
  const _PipelineCard({required this.c, required this.pending,
      required this.reviewing, required this.interview, required this.hired,
      required this.rejected, required this.total});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: ShapeDecoration(
      color: c.surface,
      shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20)),
    ),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(AppLocalizations.of(context).applications, style: TextStyle(color: c.textPrimary,
            fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(100)),
          child: Text('$total total', style: const TextStyle(
              color: AppColors.primary, fontSize: 11,
              fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ),
      ]),
      const SizedBox(height: 14),
      _PR(c: c, label: AppLocalizations.of(context).pending, count: pending, total: total, color: Colors.grey),
      const SizedBox(height: 8),
      _PR(c: c, label: AppLocalizations.of(context).reviewing, count: reviewing, total: total, color: AppColors.primary),
      const SizedBox(height: 8),
      _PR(c: c, label: AppLocalizations.of(context).interview, count: interview, total: total, color: AppColors.purple),
      const SizedBox(height: 8),
      _PR(c: c, label: AppLocalizations.of(context).hired, count: hired, total: total, color: AppColors.green),
      const SizedBox(height: 8),
      _PR(c: c, label: AppLocalizations.of(context).rejected, count: rejected, total: total, color: AppColors.red),
    ]),
  );
}

class _PR extends StatelessWidget {
  final ThemeColors c;
  final String label;
  final int count, total;
  final Color color;
  const _PR({required this.c, required this.label, required this.count,
      required this.total, required this.color});
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
    return Row(children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      SizedBox(width: 72, child: Text(label, style: TextStyle(
          color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'))),
      Expanded(child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: LinearProgressIndicator(value: pct, minHeight: 7,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color)),
      )),
      const SizedBox(width: 8),
      SizedBox(width: 20, child: Text('$count', textAlign: TextAlign.right,
          style: TextStyle(color: c.textPrimary, fontSize: 12,
              fontFamily: 'Inter', fontWeight: FontWeight.w700))),
    ]);
  }
}

class _TopJobBar extends StatelessWidget {
  final ThemeColors c;
  final int rank, applicantCount;
  final Map<String, dynamic> job;
  final double barPercent;
  const _TopJobBar({required this.c, required this.rank, required this.job,
      required this.barPercent, required this.applicantCount});
  @override
  Widget build(BuildContext context) {
    final isActive = job['isActive'] == true;
    final rankColors = [AppColors.purple, AppColors.primary, AppColors.green, Colors.orange, Colors.grey];
    final col = rankColors[(rank - 1).clamp(0, 4)];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(14)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 26, height: 26,
              decoration: BoxDecoration(color: col.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('#$rank', style: TextStyle(
                  color: col, fontSize: 10, fontFamily: 'Inter',
                  fontWeight: FontWeight.w800)))),
          const SizedBox(width: 8),
          Expanded(child: Text(job['title'] ?? 'Untitled',
              style: TextStyle(color: c.textPrimary, fontSize: 13,
                  fontFamily: 'Inter', fontWeight: FontWeight.w600),
              maxLines: 1, overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: isActive ? AppColors.greenLight : c.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(100)),
            child: Text(isActive ? 'Active' : 'Closed',
                style: TextStyle(
                    color: isActive ? AppColors.green : c.textMuted,
                    fontSize: 10, fontFamily: 'Inter',
                    fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(value: barPercent.clamp(0.0, 1.0),
                minHeight: 7, backgroundColor: col.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(col)),
          )),
          const SizedBox(width: 8),
          Text('$applicantCount', style: TextStyle(color: c.textSecondary,
              fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _RecentApps extends StatelessWidget {
  final ThemeColors c;
  final List<Map<String, dynamic>> apps;
  const _RecentApps({required this.c, required this.apps});

  Color _sc(String s) {
    switch (s) {
      case 'accepted': return AppColors.green;
      case 'rejected': return AppColors.red;
      case 'interview': return AppColors.purple;
      case 'reviewing': return AppColors.primary;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (apps.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: ShapeDecoration(color: c.surface,
            shape: RoundedRectangleBorder(
                side: BorderSide(width: 1.24, color: c.border),
                borderRadius: BorderRadius.circular(16))),
        child: Center(child: Text(AppLocalizations.of(context).noApplicationsYet,
            style: TextStyle(color: c.textMuted, fontFamily: 'Inter'))),
      );
    }
    return Container(
      decoration: ShapeDecoration(color: c.surface,
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: c.border),
              borderRadius: BorderRadius.circular(16))),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: apps.length,
        separatorBuilder: (_, __) => Divider(color: c.border, height: 1),
        itemBuilder: (_, i) {
          final app = apps[i];
          final status = app['status'] ?? 'pending';
          final name = app['applicantName'] ?? 'Anonymous';
          final parts = name.trim().split(' ');
          final initials = parts.length > 1
              ? '${parts[0][0]}${parts[1][0]}'.toUpperCase()
              : name[0].toUpperCase();
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(children: [
              Container(width: 38, height: 38,
                  decoration: BoxDecoration(color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(11)),
                  child: Center(child: Text(initials,
                      style: const TextStyle(color: AppColors.primary,
                          fontFamily: 'Inter', fontWeight: FontWeight.w700,
                          fontSize: 13)))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: TextStyle(color: c.textPrimary, fontSize: 13,
                    fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(app['offerTitle'] ?? 'Unknown job',
                    style: TextStyle(color: c.textMuted, fontSize: 11,
                        fontFamily: 'Inter'),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _sc(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: _sc(status), width: 1)),
                child: Text(status.toUpperCase(),
                    style: TextStyle(color: _sc(status), fontSize: 9,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// ── Shared small helpers ──
class _InfoRow extends StatelessWidget {
  final ThemeColors c;
  final IconData icon;
  final String label, value;
  const _InfoRow({required this.c, required this.icon,
      required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 34, height: 34,
        decoration: BoxDecoration(color: AppColors.purpleLight,
            borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.purple, size: 16)),
    const SizedBox(width: 12),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: c.textSecondary, fontSize: 11,
          fontFamily: 'Inter', fontWeight: FontWeight.w500)),
      Text(value, style: TextStyle(color: c.textPrimary, fontSize: 14,
          fontFamily: 'Inter', fontWeight: FontWeight.w600)),
    ]),
  ]);
}

class _StatItem extends StatelessWidget {
  final String value, label;
  final Color textColor, labelColor;
  const _StatItem({required this.value, required this.label,
      required this.textColor, required this.labelColor});
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: TextStyle(color: textColor, fontSize: 18,
        fontFamily: 'Inter', fontWeight: FontWeight.w700)),
    Text(label, style: TextStyle(color: labelColor, fontSize: 10,
        fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 1)),
  ]);
}

class _VDivider extends StatelessWidget {
  final ThemeColors c;
  const _VDivider({required this.c});
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32,
      color: c.border, margin: const EdgeInsets.symmetric(horizontal: 16));
}
