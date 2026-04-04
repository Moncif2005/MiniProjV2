import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/applied_job_card.dart';
import '../../services/applied_jobs_service.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  int _selectedFilter = 0;
  final _service = AppliedJobsService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  final _filterLabels = ['Tous', 'En attente', 'En révision', 'Entretien', 'Acceptés', 'Refusés'];

  ApplicationStatus? get _activeStatus {
    switch (_selectedFilter) {
      case 1: return ApplicationStatus.pending;
      case 2: return ApplicationStatus.reviewing;
      case 3: return ApplicationStatus.interview;
      case 4: return ApplicationStatus.accepted;
      case 5: return ApplicationStatus.rejected;
      default: return null;
    }
  }

  List<ApplicationModel> _applyFilter(List<ApplicationModel> all) {
    final status = _activeStatus;
    if (status == null) return all;
    return all.where((a) => a.status == status).toList();
  }

  JobStatus _toJobStatus(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.reviewing: return JobStatus.reviewing;
      case ApplicationStatus.interview: return JobStatus.interview;
      case ApplicationStatus.accepted:  return JobStatus.accepted;
      case ApplicationStatus.rejected:  return JobStatus.rejected;
      case ApplicationStatus.pending:   return JobStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final uid = _uid;

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
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                  ),
                ),
                const SizedBox(width: 16),
                uid != null
                    ? StreamBuilder<List<ApplicationModel>>(
                        stream: _service.streamApplications(uid),
                        builder: (context, snap) {
                          final count = snap.data?.length ?? 0;
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Candidatures', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                            Text('$count candidature${count > 1 ? 's' : ''} envoyée${count > 1 ? 's' : ''}',
                                style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                          ]);
                        },
                      )
                    : Text('Candidatures', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ── Overview Card ──
          uid != null
              ? StreamBuilder<List<ApplicationModel>>(
                  stream: _service.streamApplications(uid),
                  builder: (context, snap) {
                    final all        = snap.data ?? [];
                    final reviewing  = all.where((a) => a.status == ApplicationStatus.reviewing).length;
                    final interviews = all.where((a) => a.status == ApplicationStatus.interview).length;
                    final accepted   = all.where((a) => a.status == ApplicationStatus.accepted).length;
                    return _OverviewCard(reviewing: reviewing, interviews: interviews, accepted: accepted);
                  },
                )
              : const _OverviewCard(reviewing: 0, interviews: 0, accepted: 0),

          // ── Filter Chips ──
          uid != null
              ? StreamBuilder<List<ApplicationModel>>(
                  stream: _service.streamApplications(uid),
                  builder: (context, snap) {
                    final all = snap.data ?? [];
                    return _FilterChips(
                      labels: _filterLabels,
                      counts: [
                        all.length,
                        all.where((a) => a.status == ApplicationStatus.pending).length,
                        all.where((a) => a.status == ApplicationStatus.reviewing).length,
                        all.where((a) => a.status == ApplicationStatus.interview).length,
                        all.where((a) => a.status == ApplicationStatus.accepted).length,
                        all.where((a) => a.status == ApplicationStatus.rejected).length,
                      ],
                      selected: _selectedFilter,
                      onSelect: (i) => setState(() => _selectedFilter = i),
                    );
                  },
                )
              : _FilterChips(
                  labels: _filterLabels,
                  counts: List.filled(_filterLabels.length, 0),
                  selected: _selectedFilter,
                  onSelect: (i) => setState(() => _selectedFilter = i),
                ),
          const SizedBox(height: 16),

          // ── List ──
          Expanded(
            child: uid == null
                ? Center(child: Text('Non connecté', style: TextStyle(color: c.textMuted)))
                : StreamBuilder<List<ApplicationModel>>(
                    stream: _service.streamApplications(uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final filtered = _applyFilter(snap.data ?? []);

                      if (filtered.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Container(
                                width: 80, height: 80,
                                decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                                child: const Icon(Icons.work_outline_rounded, color: AppColors.primary, size: 36),
                              ),
                              const SizedBox(height: 20),
                              Text('Aucune candidature', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text("Vous n'avez pas encore\npostulé à des offres.",
                                  style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter'), textAlign: TextAlign.center),
                              const SizedBox(height: 24),
                              GestureDetector(
                                onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/offers', (route) => false),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                    Icon(Icons.search_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Voir les offres', style: TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                  ]),
                                ),
                              ),
                            ]),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final app = filtered[index];
                          return AppliedJobCard(
                            title:          app.offerTitle,
                            company:        app.company,
                            companyInitial: app.companyInitial,
                            companyBg:      Color(app.companyBgColor),
                            companyColor:   Color(app.companyColor),
                            location:       app.location,
                            jobType:        app.jobType,
                            salary:         app.salary,
                            appliedAgo:     app.appliedAgo,
                            views:          app.viewCount,
                            status:         _toJobStatus(app.status),
                            statusMessage:  app.statusMessage,
                            onViewOffer:    () {},
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
}

// ── Overview Card ────────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final int reviewing, interviews, accepted;
  const _OverviewCard({required this.reviewing, required this.interviews, required this.accepted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: AppColors.gradientBlue),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Vue d'ensemble", style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Row(children: [
          _OverviewStat(value: '$reviewing',  label: 'En révision'),
          const SizedBox(width: 32),
          _OverviewStat(value: '$interviews', label: 'Entretiens'),
          const SizedBox(width: 32),
          _OverviewStat(value: '$accepted',   label: 'Acceptés'),
        ]),
      ]),
    );
  }
}

class _OverviewStat extends StatelessWidget {
  final String value, label;
  const _OverviewStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
      Opacity(opacity: 0.8, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter'))),
    ]);
  }
}

// ── Filter Chips ─────────────────────────────────────────────────────────────
class _FilterChips extends StatelessWidget {
  final List<String> labels;
  final List<int> counts;
  final int selected;
  final ValueChanged<int> onSelect;

  const _FilterChips({required this.labels, required this.counts, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selected == index;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? c.textPrimary : c.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? c.textPrimary : c.border),
              ),
              child: Row(children: [
                Text(labels[index],
                    style: TextStyle(color: isSelected ? c.surface : c.textSecondary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white.withValues(alpha: 0.20) : c.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text('${counts[index]}',
                      style: TextStyle(color: isSelected ? Colors.white : c.textSecondary, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
