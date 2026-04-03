import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/applied_job_card.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() =>
      _AppliedJobsScreenState();
}

class _AppliedJobsScreenState
    extends State<AppliedJobsScreen> {
  int _selectedFilter = 0;

  final _filters = [
    {'label': 'Tous', 'count': 0},
    {'label': 'En attente', 'count': 0},
    {'label': 'En révision', 'count': 0},
    {'label': 'Entretien', 'count': 0},
    {'label': 'Acceptés', 'count': 0},
    {'label': 'Refusés', 'count': 0},
  ];

  // ── Empty for new users ──
  final List<Map<String, dynamic>> _jobs = [];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [

          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(
                24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(
                bottom: BorderSide(
                    color: c.border, width: 1.24),
              ),
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
                      borderRadius:
                          BorderRadius.circular(14),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Candidatures',
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_jobs.length} candidatures envoyées',
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

          // ── Overview Card ──
          Container(
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "Vue d'ensemble",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: const [
                    _OverviewStat(
                        value: '0',
                        label: 'En révision'),
                    SizedBox(width: 32),
                    _OverviewStat(
                        value: '0',
                        label: 'Entretiens'),
                    SizedBox(width: 32),
                    _OverviewStat(
                        value: '0',
                        label: 'Acceptés'),
                  ],
                ),
              ],
            ),
          ),

          // ── Filter Chips ──
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected =
                    _selectedFilter == index;
                final filter = _filters[index];
                return GestureDetector(
                  onTap: () => setState(
                      () => _selectedFilter = index),
                  child: AnimatedContainer(
                    duration: const Duration(
                        milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? c.textPrimary
                          : c.surface,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? c.textPrimary
                            : c.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          filter['label'] as String,
                          style: TextStyle(
                            color: isSelected
                                ? c.surface
                                : c.textSecondary,
                            fontSize: 13,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                    .withValues(
                                        alpha: 0.20)
                                : c.border,
                            borderRadius:
                                BorderRadius.circular(
                                    100),
                          ),
                          child: Text(
                            '${filter['count']}',
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : c.textSecondary,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // ── Empty State or List ──
          Expanded(
            child: _jobs.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryLight,
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
                            'Aucune candidature',
                            style: TextStyle(
                              color: c.textPrimary,
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Vous n\'avez pas encore\npostulé à des offres.',
                            style: TextStyle(
                              color: c.textSecondary,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/offers',
                                    (route) => false),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius:
                                    BorderRadius.circular(
                                        14),
                              ),
                              child: const Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Icon(
                                      Icons.search_rounded,
                                      color: Colors.white,
                                      size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Voir les offres',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    itemCount: _jobs.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final job = _jobs[index];
                      return AppliedJobCard(
                        title: job['title'] as String,
                        company:
                            job['company'] as String,
                        companyInitial:
                            job['initial'] as String,
                        companyBg:
                            job['companyBg'] as Color,
                        companyColor:
                            job['companyColor'] as Color,
                        location:
                            job['location'] as String,
                        jobType:
                            job['jobType'] as String,
                        salary: job['salary'] as String,
                        appliedAgo:
                            job['appliedAgo'] as String,
                        views: job['views'] as int,
                        status:
                            job['status'] as JobStatus,
                        statusMessage:
                            job['statusMessage']
                                as String?,
                        onViewOffer: () {},
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String value;
  final String label;

  const _OverviewStat(
      {required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
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
}