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
  final VoidCallback? onAction;

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
    this.onAction,
  });

  bool get _isCompleted => status == CourseStatus.completed;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 2,
            offset: Offset(0, 1),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Title Row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category,
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

              // ── Status Badge ──
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? AppColors.greenLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  _isCompleted ? 'Terminé' : 'En cours',
                  style: TextStyle(
                    color: _isCompleted
                        ? AppColors.green
                        : AppColors.primary,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Progress Bar ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: c.textSecondary,
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
              minHeight: 8,
              backgroundColor: c.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                _isCompleted
                    ? AppColors.green
                    : AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Stats Row ──
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.play_circle_outline_rounded,
                  text: lessons,
                  color: c.textSecondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.access_time_rounded,
                  text: timeSpent,
                  color: c.textSecondary,
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.calendar_today_rounded,
                  text: lastAccessed,
                  color: c.textSecondary,
                ),
              ),
            ],
          ),

          // ── Rating ──
          if (rating != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF2A2200)
                    : const Color(0xFFFEFCE8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.yellow, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Note: $rating',
                    style: const TextStyle(
                      color: AppColors.yellow,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),

          // ── Action Button ──
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                color: _isCompleted
                    ? AppColors.greenLight
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCompleted
                        ? Icons.replay_rounded
                        : Icons.play_arrow_rounded,
                    color: _isCompleted
                        ? AppColors.green
                        : Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isCompleted
                        ? 'Revoir le cours'
                        : "Continuer l'apprentissage",
                    style: TextStyle(
                      color: _isCompleted
                          ? AppColors.green
                          : Colors.white,
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: 'Inter',
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}