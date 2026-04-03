import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String rating;
  final String category;
  final String imageUrl;

  const CourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.category,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: 200,
      decoration: ShapeDecoration(
        color: c.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.24, color: c.border),
          borderRadius: BorderRadius.circular(20),
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

          // ── Thumbnail ──
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: 110,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: double.infinity,
                height: 110,
                color: c.border,
                child: Icon(
                  Icons.image_outlined,
                  color: c.textMuted,
                  size: 32,
                ),
              ),
            ),
          ),

          // ── Content ──
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Category Badge ──
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius:
                        BorderRadius.circular(100),
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
                const SizedBox(height: 8),

                // ── Title ──
                Text(
                  title,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // ── Instructor ──
                Text(
                  instructor,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // ── Rating ──
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.yellow,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(
                        color: c.textSecondary,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
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