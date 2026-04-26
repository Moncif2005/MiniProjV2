import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import '../../theme/app_colors.dart';

import '../../services/offers_service.dart';
import '../../l10n/app_localizations.dart';

class DashboardRecruteurScreen extends StatefulWidget {
  const DashboardRecruteurScreen({super.key});

  @override
  State<DashboardRecruteurScreen> createState() =>
      _DashboardRecruteurScreenState();
}

class _DashboardRecruteurScreenState extends State<DashboardRecruteurScreen> {
  final _offersService = OffersService();
  String _selectedPeriod = 'All Time';
  final List<String> _periods = ['This Week', 'This Month', 'All Time'];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final recruiterId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: recruiterId == null
            ? Center(child: Text(AppLocalizations.of(context).pleaseSignIn))
            : StreamBuilder<List<Map<String, dynamic>>>(
                stream: _offersService.getOffersByRecruiter(recruiterId),
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
                            .where('offerId',
                                whereIn: offerIds.take(10).toList())
                            .snapshots(),
                    builder: (context, appsSnap) {
                      final apps = appsSnap.data?.docs ?? [];

                      // ── Compute stats ──
                      final totalJobs = offers.length;
                      final activeJobs =
                          offers.where((o) => o['isActive'] == true).length;
                      final closedJobs = totalJobs - activeJobs;
                      final totalApplicants = offers.fold<int>(
                          0,
                          (sum, o) =>
                              sum +
                              ((o['applicationsCount'] as num?)?.toInt() ?? 0));

                      final pending = apps
                          .where((a) =>
                              (a.data() as Map)['status'] == 'pending')
                          .length;
                      final reviewing = apps
                          .where((a) =>
                              (a.data() as Map)['status'] == 'reviewing')
                          .length;
                      final interview = apps
                          .where((a) =>
                              (a.data() as Map)['status'] == 'interview')
                          .length;
                      final hired = apps
                          .where((a) =>
                              (a.data() as Map)['status'] == 'accepted')
                          .length;
                      final rejected = apps
                          .where((a) =>
                              (a.data() as Map)['status'] == 'rejected')
                          .length;

                      final totalViews = offers.fold<int>(
                          0,
                          (sum, o) =>
                              sum +
                              ((o['views'] as num?)?.toInt() ?? 0));

                      final conversionRate = totalApplicants > 0 && totalViews > 0
                          ? ((totalApplicants / totalViews) * 100)
                              .toStringAsFixed(1)
                          : '0.0';

                      // Top 3 jobs by applicants
                      final topJobs = [...offers]
                        ..sort((a, b) =>
                            ((b['applicationsCount'] as num?)?.toInt() ?? 0)
                                .compareTo(
                                    (a['applicationsCount'] as num?)?.toInt() ??
                                        0));

                      return CustomScrollView(
                        slivers: [
                          // ── Sliver Header ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context).dashboard,
                                        style: TextStyle(
                                          color: c.textPrimary,
                                          fontSize: 26,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Your recruitment overview',
                                        style: TextStyle(
                                          color: c.textSecondary,
                                          fontSize: 14,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Period Selector
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: c.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border:
                                          Border.all(color: c.border, width: 1),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _selectedPeriod,
                                        dropdownColor: c.surface,
                                        style: TextStyle(
                                          color: c.textPrimary,
                                          fontSize: 13,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                        ),
                                        icon: Icon(Icons.expand_more_rounded,
                                            color: c.textSecondary, size: 18),
                                        isDense: true,
                                        items: _periods
                                            .map((p) => DropdownMenuItem(
                                                value: p,
                                                child: Text(p)))
                                            .toList(),
                                        onChanged: (v) {
                                          if (v != null)
                                            setState(
                                                () => _selectedPeriod = v);
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // ── Hero Card ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: _HeroCard(
                                totalJobs: totalJobs,
                                activeJobs: activeJobs,
                                totalApplicants: totalApplicants,
                                hired: hired,
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // ── 4 Quick Stats ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Quick Stats',
                                    style: TextStyle(
                                      color: c.textPrimary,
                                      fontSize: 18,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _QuickStat(
                                        c: c,
                                        label: AppLocalizations.of(context).totalViews,
                                        value: '$totalViews',
                                        icon: Icons.visibility_outlined,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 12),
                                      _QuickStat(
                                        c: c,
                                        label: AppLocalizations.of(context).conversion,
                                        value: '$conversionRate%',
                                        icon: Icons.trending_up_rounded,
                                        color: AppColors.green,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _QuickStat(
                                        c: c,
                                        label: AppLocalizations.of(context).activeJobs,
                                        value: '$activeJobs',
                                        icon: Icons.work_rounded,
                                        color: AppColors.purple,
                                      ),
                                      const SizedBox(width: 12),
                                      _QuickStat(
                                        c: c,
                                        label: AppLocalizations.of(context).closedJobs,
                                        value: '$closedJobs',
                                        icon: Icons.lock_outline_rounded,
                                        color: Colors.orange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // ── Pipeline / Funnel ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: _PipelineCard(
                                c: c,
                                pending: pending,
                                reviewing: reviewing,
                                interview: interview,
                                hired: hired,
                                rejected: rejected,
                                total: apps.length,
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // ── Top Performing Jobs ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Text(
                                AppLocalizations.of(context).topJobs,
                                style: TextStyle(
                                  color: c.textPrimary,
                                  fontSize: 18,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 12)),

                          topJobs.isEmpty
                              ? SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24),
                                    child: Center(
                                      child: Text(
                                        'Post your first job to see analytics',
                                        style: TextStyle(
                                            color: c.textMuted,
                                            fontFamily: 'Inter'),
                                      ),
                                    ),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) {
                                      if (i >= topJobs.take(5).length) {
                                        return null;
                                      }
                                      final job = topJobs[i];
                                      final maxApplicants =
                                          (topJobs.first['applicationsCount']
                                                      as num?)
                                                  ?.toInt() ??
                                              1;
                                      final jobApplicants =
                                          (job['applicationsCount'] as num?)
                                                  ?.toInt() ??
                                              0;
                                      final barPercent = maxApplicants > 0
                                          ? jobApplicants / maxApplicants
                                          : 0.0;

                                      return Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            24, 0, 24, 10),
                                        child: _TopJobBar(
                                          c: c,
                                          rank: i + 1,
                                          job: job,
                                          barPercent: barPercent,
                                          applicantCount: jobApplicants,
                                        ),
                                      );
                                    },
                                    childCount: topJobs.take(5).length,
                                  ),
                                ),

                          const SliverToBoxAdapter(child: SizedBox(height: 24)),

                          // ── Recent Activity ──
                          SliverToBoxAdapter(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              child: _RecentActivity(
                                c: c,
                                apps: apps
                                    .take(5)
                                    .map((d) =>
                                        d.data() as Map<String, dynamic>)
                                    .toList(),
                              ),
                            ),
                          ),

                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

// ── Hero Card ──────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final int totalJobs, activeJobs, totalApplicants, hired;
  const _HeroCard({
    required this.totalJobs,
    required this.activeJobs,
    required this.totalApplicants,
    required this.hired,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.gradientPurple,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33AD46FF),
            blurRadius: 20,
            offset: Offset(0, 12),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).recruitmentOverview,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppLocalizations.of(context).liveAnalytics,
                    style: const TextStyle(
                      color: Color(0xFFEFD9FD),
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.dashboard_rounded,
                    color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _HeroStat(label: AppLocalizations.of(context).totalJobs, value: '$totalJobs'),
              _HeroDivider(),
              _HeroStat(label: AppLocalizations.of(context).active, value: '$activeJobs'),
              _HeroDivider(),
              _HeroStat(label: AppLocalizations.of(context).navApplicants, value: '$totalApplicants'),
              _HeroDivider(),
              _HeroStat(label: AppLocalizations.of(context).hired, value: '$hired'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  final String label, value;
  const _HeroStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFEFD9FD),
                fontSize: 11,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
}

class _HeroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: 1,
        height: 40,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

// ── Quick Stat Card ────────────────────────────────────────────
class _QuickStat extends StatelessWidget {
  final ThemeColors c;
  final String label, value;
  final IconData icon;
  final Color color;
  const _QuickStat({
    required this.c,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: ShapeDecoration(
            color: c.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: c.border),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 11,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

// ── Pipeline Card ──────────────────────────────────────────────
class _PipelineCard extends StatelessWidget {
  final ThemeColors c;
  final int pending, reviewing, interview, hired, rejected, total;
  const _PipelineCard({
    required this.c,
    required this.pending,
    required this.reviewing,
    required this.interview,
    required this.hired,
    required this.rejected,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context).recruitmentPipeline,
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$total total',
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
          const SizedBox(height: 16),
          _PipelineStep(
              c: c,
              label: 'Pending Review',
              count: pending,
              total: total,
              color: Colors.grey),
          const SizedBox(height: 10),
          _PipelineStep(
              c: c,
              label: 'Under Review',
              count: reviewing,
              total: total,
              color: AppColors.primary),
          const SizedBox(height: 10),
          _PipelineStep(
              c: c,
              label: 'Interview Stage',
              count: interview,
              total: total,
              color: AppColors.purple),
          const SizedBox(height: 10),
          _PipelineStep(
              c: c,
              label: AppLocalizations.of(context).hired,
              count: hired,
              total: total,
              color: AppColors.green),
          const SizedBox(height: 10),
          _PipelineStep(
              c: c,
              label: AppLocalizations.of(context).rejected,
              count: rejected,
              total: total,
              color: AppColors.red),
        ],
      ),
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final ThemeColors c;
  final String label;
  final int count, total;
  final Color color;
  const _PipelineStep({
    required this.c,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            Text(
              '$count',
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 13,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: pct.clamp(0.0, 1.0),
            minHeight: 6,
            backgroundColor: color.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ── Top Job Bar ────────────────────────────────────────────────
class _TopJobBar extends StatelessWidget {
  final ThemeColors c;
  final int rank;
  final Map<String, dynamic> job;
  final double barPercent;
  final int applicantCount;
  const _TopJobBar({
    required this.c,
    required this.rank,
    required this.job,
    required this.barPercent,
    required this.applicantCount,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = job['isActive'] == true;
    final rankColors = [
      AppColors.purple,
      AppColors.primary,
      AppColors.green,
      Colors.orange,
      Colors.grey,
    ];
    final rankColor = rankColors[(rank - 1).clamp(0, 4)];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: TextStyle(
                      color: rankColor,
                      fontSize: 11,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  job['title'] ?? 'Untitled',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.greenLight
                      : c.border.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  isActive ? AppLocalizations.of(context).active : AppLocalizations.of(context).jobClosed,
                  style: TextStyle(
                    color: isActive ? AppColors.green : c.textMuted,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: barPercent.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: rankColor.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$applicantCount applicants',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recent Activity ────────────────────────────────────────────
class _RecentActivity extends StatelessWidget {
  final ThemeColors c;
  final List<Map<String, dynamic>> apps;
  const _RecentActivity({required this.c, required this.apps});

  Color _statusColor(String s) {
    switch (s) {
      case 'accepted':
        return AppColors.green;
      case 'rejected':
        return AppColors.red;
      case 'interview':
        return AppColors.purple;
      case 'reviewing':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).recentApplications,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 18,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        apps.isEmpty
            ? Container(
                padding: const EdgeInsets.all(24),
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context).noApplicationsYet,
                    style: TextStyle(color: c.textMuted, fontFamily: 'Inter'),
                  ),
                ),
              )
            : Container(
                decoration: ShapeDecoration(
                  color: c.surface,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.24, color: c.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: apps.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: c.border, height: 1),
                  itemBuilder: (_, i) {
                    final app = apps[i];
                    final status = app['status'] ?? 'pending';
                    final name = app['applicantName'] ?? 'Anonymous';
                    final offerTitle = app['offerTitle'] ?? 'Unknown job';
                    final initials = name.trim().split(' ').length > 1
                        ? '${name.trim().split(' ')[0][0]}${name.trim().split(' ')[1][0]}'
                            .toUpperCase()
                        : name[0].toUpperCase();

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: c.textPrimary,
                                    fontSize: 14,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  offerTitle,
                                  style: TextStyle(
                                    color: c.textMuted,
                                    fontSize: 12,
                                    fontFamily: 'Inter',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                  color: _statusColor(status), width: 1),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _statusColor(status),
                                fontSize: 10,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}
