import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CourseStatus { inProgress, completed }

class LearningCourseCard extends StatelessWidget {
  final String title;
  final String category;
  final CourseStatus status;
  final double progress;
  final String lessons;
  final String timeSpent;
  final String lastAccessed;
  final String? rating;
  final VoidCallback onAction;

  const LearningCourseCard({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    required this.progress,
    required this.lessons,
    required this.timeSpent,
    required this.lastAccessed,
    this.rating,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isCompleted = status == CourseStatus.completed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──
          Row(
            children: [
              // Course icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.greenLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.menu_book_rounded,
                  color: isCompleted ? AppColors.green : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Category badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            category,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.greenLight
                                : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            isCompleted ? 'Completed' : 'In Progress',
                            style: TextStyle(
                              color: isCompleted
                                  ? AppColors.green
                                  : AppColors.orange,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Rating (if completed)
              if (isCompleted && rating != null)
                Column(
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFD08700), size: 16),
                    Text(
                      rating!,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Progress bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lessons,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: isCompleted ? AppColors.green : AppColors.primary,
                  fontSize: 12,
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
              value: progress,
              minHeight: 6,
              backgroundColor: isCompleted
                  ? AppColors.greenLight
                  : AppColors.primaryLight,
              valueColor: AlwaysStoppedAnimation(
                isCompleted ? AppColors.green : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Footer row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 13, color: c.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    timeSpent,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.calendar_today_rounded,
                      size: 13, color: c.textMuted),
                  const SizedBox(width: 4),
                  Text(
                    lastAccessed,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.greenLight
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCompleted ? 'Review' : 'Continue',
                    style: TextStyle(
                      color: isCompleted
                          ? AppColors.green
                          : AppColors.primary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
