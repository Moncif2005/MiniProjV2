import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../services/lessons_service.dart';
import '../../services/learn_service.dart';
import '../../screens/shared/lesson_player_screen.dart';
import '../../l10n/app_localizations.dart';

enum LessonItemStatus { completed, current, locked }

class LessonScreen extends StatelessWidget {
  final String courseId;

  const LessonScreen({super.key, required this.courseId});

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

    final lessonsService = LessonsService();
    final learnService = LearnService();

    return Scaffold(
      backgroundColor: c.bg,
      body: FutureBuilder<CourseModel?>(
        future: learnService.fetchCourse(courseId),
        builder: (context, courseSnap) {
          final course = courseSnap.data;

          return Column(
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            course?.title ?? AppLocalizations.of(context).loading,
                            style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          if (course != null)
                            Text(
                              '${course.lessonsCount} ${AppLocalizations.of(context).lessons}',
                              style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Content ──
              Expanded(
                child: StreamBuilder<List<LessonModel>>(
                  stream: lessonsService.streamLessons(courseId),
                  builder: (context, lessonsSnap) {
                    if (lessonsSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final lessons = lessonsSnap.data ?? [];

                    return StreamBuilder<LessonProgress>(
                      stream: lessonsService.streamProgress(uid, courseId),
                      builder: (context, progressSnap) {
                        final progress = progressSnap.data ?? LessonProgress.empty();
                        final completedIds = progress.completedLessonIds.toSet();
                        final total = lessons.length;
                        final completedCount = completedIds.length;
                        final progressPercent = total > 0 ? completedCount / total : 0.0;

                        // First non-completed lesson = current
                        String? currentLessonId;
                        for (final l in lessons) {
                          if (!completedIds.contains(l.id)) { currentLessonId = l.id; break; }
                        }

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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(AppLocalizations.of(context).courseProgress,
                                            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: const BoxDecoration(color: Color(0x33FFFFFF), borderRadius: BorderRadius.all(Radius.circular(100))),
                                          child: Text(
                                            '$completedCount/$total ${AppLocalizations.of(context).lessons}',
                                            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: LinearProgressIndicator(
                                        value: progressPercent, minHeight: 8,
                                        backgroundColor: const Color(0x40FFFFFF),
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${(progressPercent * 100).toInt()}% ${AppLocalizations.of(context).completed}',
                                      style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              Text(AppLocalizations.of(context).lessonsLabel,
                                  style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),

                              if (lessons.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(AppLocalizations.of(context).noLessonsYet,
                                        style: TextStyle(color: c.textMuted, fontFamily: 'Inter')),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: lessons.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final lesson = lessons[index];
                                    final isCompleted = completedIds.contains(lesson.id);
                                    final isCurrent = lesson.id == currentLessonId && !isCompleted;
                                    final isLocked = !isCompleted && !isCurrent && !lesson.isFree;
                                    final status = isCompleted
                                        ? LessonItemStatus.completed
                                        : isCurrent ? LessonItemStatus.current : LessonItemStatus.locked;

                                    return _LessonItem(
                                      number: index + 1,
                                      lesson: lesson,
                                      status: status,
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => LessonPlayerScreen(
                                          videoUrl: lesson.videoUrl ?? '',
                                          lessonTitle: lesson.title,
                                          courseId: courseId,
                                          lessonId: lesson.id,
                                          lessonType: 'video',
                                          isLocked: isLocked,
                                          description: lesson.description,
                                        ),
                                      )),
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
          );
        },
      ),
    );
  }
}

class _LessonItem extends StatelessWidget {
  final int number;
  final LessonModel lesson;
  final LessonItemStatus status;
  final VoidCallback onTap;

  const _LessonItem({required this.number, required this.lesson, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.title,
                      style: TextStyle(color: isLocked ? c.textMuted : c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 12, color: c.textMuted),
                      const SizedBox(width: 4),
                      Text(lesson.durationFormatted, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Inter')),
                      if (lesson.isFree) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(100)),
                          child: const Text('Free', style: TextStyle(color: AppColors.green, fontSize: 10, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isCompleted)
              const Icon(Icons.replay_rounded, color: AppColors.green, size: 18)
            else if (isCurrent)
              const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20)
            else
              Icon(Icons.lock_outline_rounded, color: c.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
