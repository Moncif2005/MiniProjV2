import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/lessons_service.dart';
import '../../../services/learning_history_service.dart';

// ── Route args ──────────────────────────────────────────────────────────────
class LessonScreenArgs {
  final String courseId;
  final String courseTitle;
  final int totalLessons;
  const LessonScreenArgs({required this.courseId, required this.courseTitle, required this.totalLessons});
}

enum LessonItemStatus { completed, current, locked }

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _lessonsService        = LessonsService();
  final _learningHistoryService = LearningHistoryService();

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // args passed via Navigator
  LessonScreenArgs? _args;
  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      _args = ModalRoute.of(context)?.settings.arguments as LessonScreenArgs?;
      _argsLoaded = true;
    }
  }

  Future<void> _markComplete(LessonModel lesson, LessonProgress progress) async {
    final uid = _uid;
    if (uid == null || _args == null) return;

    await _lessonsService.completeLesson(
      uid:          uid,
      courseId:     _args!.courseId,
      lessonId:     lesson.id,
      totalLessons: _args!.totalLessons,
    );

    final newCompleted = progress.completedLessonIds.length +
        (progress.completedLessonIds.contains(lesson.id) ? 0 : 1);

    await _learningHistoryService.updateProgress(
      uid:              uid,
      courseId:         _args!.courseId,
      completedLessons: newCompleted,
      totalLessons:     _args!.totalLessons,
      addMinutes:       lesson.durationMinutes,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Leçon "${lesson.title}" terminée ✓'),
      backgroundColor: AppColors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  LessonItemStatus _statusFor(LessonModel lesson, LessonProgress progress, int index, List<LessonModel> all) {
    if (progress.completedLessonIds.contains(lesson.id)) return LessonItemStatus.completed;
    // current = first non-completed
    for (int i = 0; i < all.length; i++) {
      if (!progress.completedLessonIds.contains(all[i].id)) {
        return i == index ? LessonItemStatus.current : LessonItemStatus.locked;
      }
    }
    return LessonItemStatus.locked;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // ── Fallback: no args (navigated without args) ──
    final courseId    = _args?.courseId    ?? '';
    final courseTitle = _args?.courseTitle ?? 'Cours';

    if (courseId.isEmpty) {
      return Scaffold(
        backgroundColor: c.bg,
        body: Center(child: Text('Aucun cours sélectionné', style: TextStyle(color: c.textMuted))),
      );
    }

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
                Expanded(
                  child: StreamBuilder<LessonProgress>(
                    stream: _uid != null ? _lessonsService.streamProgress(_uid!, courseId) : null,
                    builder: (context, progressSnap) {
                      return StreamBuilder<List<LessonModel>>(
                        stream: _lessonsService.streamLessons(courseId),
                        builder: (context, lessonsSnap) {
                          final total     = lessonsSnap.data?.length ?? 0;
                          final completed = progressSnap.data?.completedLessonIds.length ?? 0;
                          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(courseTitle, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                            Text('$total leçons • $completed complétées', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                          ]);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          Expanded(
            child: StreamBuilder<List<LessonModel>>(
              stream: _lessonsService.streamLessons(courseId),
              builder: (context, lessonsSnap) {
                if (lessonsSnap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (lessonsSnap.hasError) {
                  return Center(child: Text('Erreur', style: TextStyle(color: c.textMuted)));
                }
                final lessons = lessonsSnap.data ?? [];

                return StreamBuilder<LessonProgress>(
                  stream: _uid != null ? _lessonsService.streamProgress(_uid!, courseId) : Stream.value(LessonProgress.empty()),
                  builder: (context, progressSnap) {
                    final progress = progressSnap.data ?? LessonProgress.empty();
                    final completed = progress.completedLessonIds.length;
                    final total     = lessons.length;
                    final pct       = total > 0 ? completed / total : 0.0;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Progress Card ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft, end: Alignment.bottomRight,
                                colors: AppColors.gradientBlue,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(24)),
                              boxShadow: [BoxShadow(color: Color(0x33155DFC), blurRadius: 12, offset: Offset(0, 4), spreadRadius: -4)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                  const Text('Progression du cours',
                                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: const BoxDecoration(color: Color(0x33FFFFFF), borderRadius: BorderRadius.all(Radius.circular(100))),
                                    child: Text('$completed/$total leçons',
                                        style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                  ),
                                ]),
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: LinearProgressIndicator(
                                    value: pct, minHeight: 8,
                                    backgroundColor: const Color(0x40FFFFFF),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text('${(pct * 100).toInt()}% complété',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Lessons Title ──
                          Text('Leçons', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),

                          // ── Lessons List ──
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: lessons.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final lesson = lessons[index];
                              final status = _statusFor(lesson, progress, index, lessons);
                              return _LessonItem(
                                number:   lesson.order,
                                title:    lesson.title,
                                duration: lesson.durationFormatted,
                                status:   status,
                                onTap:    status != LessonItemStatus.locked
                                    ? () => _markComplete(lesson, progress)
                                    : null,
                              );
                            },
                          ),
                          const SizedBox(height: 32),
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

// ── Lesson Item ──────────────────────────────────────────────────────────────
class _LessonItem extends StatelessWidget {
  final int number;
  final String title;
  final String duration;
  final LessonItemStatus status;
  final VoidCallback? onTap;

  const _LessonItem({required this.number, required this.title, required this.duration, required this.status, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c          = context.colors;
    final isCompleted = status == LessonItemStatus.completed;
    final isCurrent   = status == LessonItemStatus.current;
    final isLocked    = status == LessonItemStatus.locked;
    final currentBg   = context.isDark ? const Color(0xFF1A2A4A) : AppColors.primaryLight;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isCurrent ? currentBg : c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: isCurrent ? AppColors.primary : c.border),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: const [BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.greenLight : isCurrent ? AppColors.primary : c.iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.green, size: 18)
                    : isLocked
                        ? Icon(Icons.lock_rounded, color: c.textMuted, size: 16)
                        : Text('$number', style: const TextStyle(color: Colors.white, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(color: isLocked ? c.textMuted : c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(Icons.access_time_rounded, size: 12, color: c.textMuted),
                  const SizedBox(width: 4),
                  Text(duration, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
                ]),
              ]),
            ),
            if (isCompleted)      const Icon(Icons.replay_rounded,         color: AppColors.green,   size: 18)
            else if (isCurrent)   const Icon(Icons.play_arrow_rounded,     color: AppColors.primary, size: 20)
            else                  Icon(Icons.lock_outline_rounded, color: c.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
