import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/learning_history_service.dart';
import '../../screens/shared/lesson_screen.dart';
import '../../widgets/learning_course_card.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  String _formatTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Text(AppLocalizations.of(context).pleaseSignIn,
              style: TextStyle(color: c.textMuted)),
        ),
      );
    }

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
                FutureBuilder<Map<String, dynamic>>(
                  future: service.fetchLearningStats(uid),
                  builder: (context, snap) {
                    final stats = snap.data ?? {};
                    final totalMin = stats['totalLearningMinutes'] ?? 0;
                    final enrolled = stats['enrolledCourses'] ?? 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).learningHistory,
                          style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '$enrolled ${AppLocalizations.of(context).courses} • ${_formatTime(totalMin)} ${AppLocalizations.of(context).ofLearning}',
                          style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Scrollable Content ──
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: service.fetchLearningStats(uid),
              builder: (context, statsSnap) {
                final stats = statsSnap.data ?? {};
                final enrolled   = stats['enrolledCourses']      ?? 0;
                final completed  = stats['completedCourses']      ?? 0;
                final streak     = stats['streakDays']            ?? 0;
                final totalMin   = stats['totalLearningMinutes']  ?? 0;

                final statItems = [
                  {
                    'value': '$enrolled',
                    'label': AppLocalizations.of(context).activeCourses,
                    'icon': Icons.school_rounded,
                    'colors': [const Color(0xFF2B7FFF), const Color(0xFF4F39F6)],
                  },
                  {
                    'value': '$completed',
                    'label': AppLocalizations.of(context).completedCourses,
                    'icon': Icons.check_circle_rounded,
                    'colors': [const Color(0xFF00C950), const Color(0xFF009966)],
                  },
                  {
                    'value': '$streak',
                    'label': AppLocalizations.of(context).consecutiveDays,
                    'icon': Icons.local_fire_department_rounded,
                    'colors': [const Color(0xFFFF6900), const Color(0xFFE7000B)],
                  },
                  {
                    'value': _formatTime(totalMin),
                    'label': AppLocalizations.of(context).ofLearning,
                    'icon': Icons.access_time_rounded,
                    'colors': [const Color(0xFFAD46FF), const Color(0xFFE60076)],
                  },
                ];

                return StreamBuilder<List<EnrollmentModel>>(
                  stream: service.streamEnrollments(uid),
                  builder: (context, enrollSnap) {
                    if (enrollSnap.connectionState == ConnectionState.waiting) {
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
                            itemCount: statItems.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.04,
                            ),
                            itemBuilder: (context, index) {
                              final stat = statItems[index];
                              return _StatCard(
                                value:  stat['value']  as String,
                                label:  stat['label']  as String,
                                icon:   stat['icon']   as IconData,
                                colors: stat['colors'] as List<Color>,
                              );
                            },
                          ),
                          const SizedBox(height: 28),

                          Text(
                            AppLocalizations.of(context).allCourses,
                            style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 16),

                          if (enrollments.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  children: [
                                    Icon(Icons.school_outlined, size: 48, color: c.textMuted),
                                    const SizedBox(height: 12),
                                    Text(
                                      AppLocalizations.of(context).noEnrollmentsYet,
                                      style: TextStyle(color: c.textMuted, fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
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
                                  onAction: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => LessonScreen(courseId: e.courseId),
                                    ),
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

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.20), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 30, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Opacity(
            opacity: 0.80,
            child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter')),
          ),
        ],
      ),
    );
  }
}
