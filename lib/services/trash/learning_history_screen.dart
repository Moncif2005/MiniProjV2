import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/theme/app_colors.dart';
import '../../../services/learning_history_service.dart';
import '../../../widgets/learning_course_card.dart';

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  static const _statMeta = [
    {'label': 'cours actifs',      'icon': Icons.school_rounded,                'colors': [Color(0xFF2B7FFF), Color(0xFF4F39F6)], 'key': 'activeCourses'},
    {'label': 'cours complétés',   'icon': Icons.check_circle_rounded,          'colors': [Color(0xFF00C950), Color(0xFF009966)], 'key': 'completedCourses'},
    {'label': 'jours consécutifs', 'icon': Icons.local_fire_department_rounded, 'colors': [Color(0xFFFF6900), Color(0xFFE7000B)], 'key': 'streakDays'},
    {'label': "d'apprentissage",   'icon': Icons.access_time_rounded,           'colors': [Color(0xFFAD46FF), Color(0xFFE60076)], 'key': 'totalHours'},
  ];

  String _statValue(Map<String, dynamic> stats, String key) {
    switch (key) {
      case 'activeCourses':
        final enrolled   = (stats['enrolledCourses']  ?? 0) as int;
        final completed  = (stats['completedCourses'] ?? 0) as int;
        return '${enrolled - completed}';
      case 'completedCourses': return '${stats['completedCourses'] ?? 0}';
      case 'streakDays':       return '${stats['streakDays']       ?? 0}';
      case 'totalHours':
        final minutes = (stats['totalLearningMinutes'] ?? 0) as int;
        final h = minutes ~/ 60;
        final m = minutes % 60;
        return m == 0 ? '${h}h' : '$h.${(m / 6).round()}h';
      default: return '0';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final uid = _uid;
    final service = LearningHistoryService();

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
                    ? StreamBuilder<List<EnrollmentModel>>(
                        stream: service.streamEnrollments(uid),
                        builder: (context, snap) {
                          final count   = snap.data?.length ?? 0;
                          final minutes = snap.data?.fold<int>(0, (s, e) => s + e.timeSpentMinutes) ?? 0;
                          final h = minutes ~/ 60;
                          final m = minutes % 60;
                          final timeStr = m == 0 ? '${h}h' : '${h}h ${m}min';
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("Historique d'apprentissage",
                                style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                            Text("$count cours • $timeStr d'apprentissage",
                                style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                          ]);
                        },
                      )
                    : Text("Historique d'apprentissage",
                        style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: uid == null
                ? Center(child: Text('Non connecté', style: TextStyle(color: c.textMuted)))
                : FutureBuilder<Map<String, dynamic>>(
                    future: service.fetchLearningStats(uid),
                    builder: (context, statsSnap) {
                      final stats = statsSnap.data ?? {};
                      return StreamBuilder<List<EnrollmentModel>>(
                        stream: service.streamEnrollments(uid),
                        builder: (context, enrollSnap) {
                          if (enrollSnap.connectionState == ConnectionState.waiting && !enrollSnap.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final enrollments = enrollSnap.data ?? [];

                          return SingleChildScrollView(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ── Stats Grid ──
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _statMeta.length,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 1.04,
                                  ),
                                  itemBuilder: (context, index) {
                                    final meta = _statMeta[index];
                                    return _StatCard(
                                      value:  _statValue(stats, meta['key'] as String),
                                      label:  meta['label'] as String,
                                      icon:   meta['icon']  as IconData,
                                      colors: meta['colors'] as List<Color>,
                                    );
                                  },
                                ),
                                const SizedBox(height: 28),

                                // ── Section Title ──
                                Text('Tous les cours',
                                    style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                const SizedBox(height: 16),

                                // ── Enrollment Cards ──
                                enrollments.isEmpty
                                    ? Center(child: Padding(
                                        padding: const EdgeInsets.only(top: 32),
                                        child: Column(children: [
                                          Icon(Icons.school_outlined, color: c.textMuted, size: 48),
                                          const SizedBox(height: 12),
                                          Text('Aucun cours inscrit', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                                        ]),
                                      ))
                                    : ListView.separated(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: enrollments.length,
                                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                                        itemBuilder: (context, index) {
                                          final e = enrollments[index];
                                          return LearningCourseCard(
                                            title:        e.courseTitle,
                                            category:     e.category,
                                            status:       e.isCompleted ? CourseStatus.completed : CourseStatus.inProgress,
                                            progress:     e.progressPercent,
                                            lessons:      e.lessonsLabel,
                                            timeSpent:    e.timeSpentFormatted,
                                            lastAccessed: e.lastAccessedLabel,
                                            rating:       e.ratingEmoji,
                                            onAction: () => Navigator.pushNamed(
                                              context, '/lesson',
                                              arguments: {'courseId': e.courseId, 'courseTitle': e.courseTitle},
                                            ),
                                          );
                                        },
                                      ),
                                const SizedBox(height: 24),
                              ],
                            ),
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

// ── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final List<Color> colors;

  const _StatCard({required this.value, required this.label, required this.icon, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4), spreadRadius: -4),
          BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10), spreadRadius: -3),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36, padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Opacity(opacity: 0.80, child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter'))),
      ]),
    );
  }
}
