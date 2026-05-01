import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LearnCourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String rating;
  final String duration;
  final String lessons;
  final String category;
  final String imageUrl;
  final bool hasQuizGames;
  final VoidCallback? onEnroll;
  final VoidCallback? onBookmark;

  const LearnCourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.duration,
    required this.lessons,
    required this.category,
    required this.imageUrl,
    this.hasQuizGames = false,
    this.onEnroll,
    this.onBookmark,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;

    final overlayBg = isDark
        ? Colors.black.withOpacity(0.55)
        : Colors.white.withOpacity(0.90);
    final overlayIcon = isDark ? Colors.white : const Color(0xFF155DFC);

    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : const Color(0x19000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: -1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 192,
                    color: c.iconBg,
                    child: Center(
                      child: Icon(Icons.image_outlined, color: c.textMuted, size: 48),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    _Badge(
                      label: category.toUpperCase(),
                      bgColor: overlayBg,
                      textColor: AppColors.primary,
                      isRounded: true,
                    ),
                    if (hasQuizGames) ...[
                      const SizedBox(width: 8),
                      _Badge(
                        label: '🎮 QUIZ + GAMES',
                        bgColor: const Color(0xE500C950),
                        textColor: Colors.white,
                        isRounded: true,
                      ),
                    ],
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onBookmark,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: overlayBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.4 : 0.10),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Icon(Icons.bookmark_border_rounded, color: overlayIcon, size: 24),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'By $instructor',
                  style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 12),
                Divider(color: c.border, thickness: 1.24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, color: c.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(duration, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                        const SizedBox(width: 16),
                        Icon(Icons.play_circle_outline_rounded, color: c.textSecondary, size: 16),
                        const SizedBox(width: 4),
                        Text(lessons, style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                      ],
                    ),
                    GestureDetector(
                      onTap: onEnroll,
                      child: Text(
                        'Enroll Now',
                        style: TextStyle(
                          color: isDark ? AppColors.darkPrimary : AppColors.primary,
                          fontSize: 14,
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
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final bool isRounded;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.isRounded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(isRounded ? 100 : 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
