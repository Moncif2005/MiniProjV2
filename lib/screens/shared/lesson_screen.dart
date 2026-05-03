import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/models/course_model.dart';
import '../../theme/app_colors.dart';
import '../../services/lessons_service.dart';
import '../../services/learn_service.dart';
import '../../screens/shared/lesson_player_screen.dart';
import '../../l10n/app_localizations.dart';

enum LessonItemStatus { completed, current, locked }

class LessonScreen extends StatelessWidget {
  final String courseId;
  const LessonScreen({super.key, required this.courseId});

  // ✅ دالة لتحديد لون التمييز حسب الكورس (يمكن تمريرها أو جلبها من البيانات)
  Color _getAccentColor(String? category) {
    if (category == null) return AppColors.primary;
    switch (category.toLowerCase()) {
      case 'coding': return AppColors.cyan;
      case 'design': return AppColors.purple;
      case 'langues': return AppColors.green;
      case 'business': return AppColors.orange;
      case 'marketing': return AppColors.pink;
      default: return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 48, color: c.textMuted),
              const SizedBox(height: 12),
              Text(AppLocalizations.of(context).pleaseSignIn, style: TextStyle(color: c.textMuted, fontFamily: 'Inter')),
            ],
          ),
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
          final accentColor = _getAccentColor(course?.category);

          return Column(
            children: [
              // ── App Bar (محسّن) ──
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
                        decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.border)),
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
if (course != null) ...[
  Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: accentColor.withOpacity(0.3)),
        ),
        child: Text(
          course.category,
          style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        ),
      ),
      const SizedBox(width: 8),
      // ✅✅✅ التصحيح هنا ✅✅✅
      Text(
        '${course.totalLessons} ${AppLocalizations.of(context).lessons}',
        style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
      ),
    ],
  ),
],                        ],
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
                              // ── Progress Card (محسّن مثل CourseDetails) ──
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [accentColor, accentColor.withOpacity(0.7)]),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [BoxShadow(color: accentColor.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -4)],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                              child: Icon(Icons.trending_up_rounded, color: Colors.white, size: 16),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(AppLocalizations.of(context).courseProgress, style: const TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(100), border: Border.all(color: Colors.white.withOpacity(0.3))),
                                          child: Text('$completedCount/$total', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: LinearProgressIndicator(
                                        value: progressPercent, minHeight: 8,
                                        backgroundColor: Colors.white.withOpacity(0.3),
                                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text('${(progressPercent * 100).toInt()}% ${AppLocalizations.of(context).completed}', style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Lessons Header ──
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(AppLocalizations.of(context).lessonsLabel, style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                                  _LessonStatusLegend(c: c, accentColor: accentColor),
                                ],
                              ),
                              const SizedBox(height: 16),

                              if (lessons.isEmpty)
                                _EmptyLessonsState(c: c)
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
                                    final status = isCompleted ? LessonItemStatus.completed : isCurrent ? LessonItemStatus.current : LessonItemStatus.locked;

                                    return _LessonItem(
                                      number: index + 1,
                                      lesson: lesson,
                                      status: status,
                                      accentColor: accentColor, // ✅ تمرير اللون للبطاقة
                                      onTap: () => Navigator.push(context, MaterialPageRoute(
                                        builder: (_) => LessonPlayerScreen(
                                          videoUrl: lesson.videoUrl ?? '',
                                          lessonTitle: lesson.title,
                                          courseId: courseId,
                                          lessonId: lesson.id,
                                          lessonType: 'video',
                                          isLocked: isLocked,
                                          description: lesson.description,
                                          // ✅ تمرير isFirstLesson للتتبع
                                          isFirstLesson: index == 0,
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

// ── Legend for lesson statuses (محسّن) ──
class _LessonStatusLegend extends StatelessWidget {
  final ThemeColors c;
  final Color accentColor;
  const _LessonStatusLegend({required this.c, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendDot(color: AppColors.green, label: 'Done'),
        const SizedBox(width: 12),
        _LegendDot(color: accentColor, label: 'Current', isBorder: true),
        const SizedBox(width: 12),
        _LegendDot(color: c.iconBg, label: 'Locked', isLocked: true),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isBorder, isLocked;
  const _LegendDot({required this.color, required this.label, this.isBorder = false, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: isLocked ? null : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
            border: isBorder ? Border.all(color: color, width: 2) : (isLocked ? Border.all(color: context.colors.textMuted, width: 1) : null),
          ),
          child: isLocked ? Icon(Icons.lock_rounded, size: 8, color: context.colors.textMuted) : null,
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: context.colors.textMuted, fontSize: 10, fontFamily: 'Inter')),
      ],
    );
  }
}

// ── Empty State (محسّن) ──
class _EmptyLessonsState extends StatelessWidget {
  final ThemeColors c;
  const _EmptyLessonsState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: c.surface2, borderRadius: BorderRadius.circular(16), border: Border.all(color: c.border)),
      child: Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 48, color: c.textMuted),
          const SizedBox(height: 12),
          Text(AppLocalizations.of(context).noLessonsYet, style: TextStyle(color: c.textPrimary, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('Check back soon for new content!', style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

// ── Lesson Item Card (محسّن جداً ليتناسق مع النظام) ──
class _LessonItem extends StatelessWidget {
  final int number;
  final LessonModel lesson;
  final LessonItemStatus status;
  final Color accentColor; // ✅ جديد
  final VoidCallback onTap;

  const _LessonItem({required this.number, required this.lesson, required this.status, required this.accentColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isCompleted = status == LessonItemStatus.completed;
    final isCurrent   = status == LessonItemStatus.current;
    final isLocked    = status == LessonItemStatus.locked;

    // ألوان ديناميكية حسب الحالة
    final bgColor = isCurrent ? accentColor.withOpacity(context.isDark ? 0.15 : 0.08) : c.surface;
    final borderColor = isCurrent ? accentColor : (isCompleted ? AppColors.green.withOpacity(0.3) : c.border);
    final textColor = isLocked ? c.textMuted.withOpacity(0.7) : c.textPrimary;
    final iconColor = isCompleted ? AppColors.green : (isLocked ? c.textMuted : accentColor);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: bgColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: isCurrent ? [BoxShadow(color: accentColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2))] : [const BoxShadow(color: Color(0x19000000), blurRadius: 2, offset: Offset(0, 1), spreadRadius: -1)],
        ),
        child: Row(
          children: [
            // ✅ رقم/أيقونة الدرس (مصمم مثل _DetailPill)
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.green.withOpacity(0.12) : (isLocked ? c.iconBg : accentColor.withOpacity(0.12)),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isCompleted ? AppColors.green.withOpacity(0.3) : (isLocked ? c.border : accentColor.withOpacity(0.3))),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: AppColors.green, size: 18)
                    : isLocked
                        ? Icon(Icons.lock_rounded, color: c.textMuted, size: 14)
                        : Text('$number', style: TextStyle(color: accentColor, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // العنوان
                  Text(lesson.title, style: TextStyle(color: textColor, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  // التفاصيل الصغيرة
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded, size: 11, color: c.textMuted),
                      const SizedBox(width: 3),
                      Text(lesson.durationFormatted, style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                      if (lesson.isFree) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(100), border: Border.all(color: AppColors.green.withOpacity(0.3))),
                          child: const Text('Free', style: TextStyle(color: AppColors.green, fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // ✅ أيقونة الحالة (يمين)
            if (isCompleted)
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18))
            else if (isCurrent)
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.play_circle_rounded, color: accentColor, size: 18))
            else
              Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: c.iconBg, borderRadius: BorderRadius.circular(8)), child: Icon(Icons.lock_outline_rounded, color: c.textMuted, size: 16)),
          ],
        ),
      ),
    );
  }
}