import 'package:flutter/material.dart';

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
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1.24, color: Color(0xFFF5F5F5)),
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

          // ── Thumbnail ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24)),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 192,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 192,
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(Icons.image_outlined,
                          color: Color(0xFFA1A1A1), size: 48),
                    ),
                  ),
                ),
              ),

              // ── Category Badge ──
              Positioned(
                top: 16,
                left: 16,
                child: Row(
                  children: [
                    _Badge(
                      label: category.toUpperCase(),
                      bgColor: Colors.white.withValues(alpha: 0.90),
                      textColor: const Color(0xFF155DFC),
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

              // ── Bookmark Button ──
              Positioned(
                bottom: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onBookmark,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.90),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: Color(0x19000000),
                          blurRadius: 15,
                          offset: Offset(0, 10),
                          spreadRadius: -3,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bookmark_border_rounded,
                      color: Color(0xFF155DFC),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Course Info ──
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Title + Rating ──
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF171717),
                          fontSize: 18,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Color(0xFFFBBF24), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: const TextStyle(
                            color: Color(0xFF0A0A0A),
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

                // ── Instructor ──
                Text(
                  'By $instructor',
                  style: const TextStyle(
                    color: Color(0xFF737373),
                    fontSize: 14,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 12),

                // ── Divider ──
                const Divider(color: Color(0xFFFAFAFA), thickness: 1.24),

                // ── Meta + Enroll ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    // ── Duration & Lessons ──
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            color: Color(0xFF737373), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.play_circle_outline_rounded,
                            color: Color(0xFF737373), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          lessons,
                          style: const TextStyle(
                            color: Color(0xFF737373),
                            fontSize: 12,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),

                    // ── Enroll Button ──
                    GestureDetector(
                      onTap: onEnroll,
                      child: const Text(
                        'Enroll Now',
                        style: TextStyle(
                          color: Color(0xFF155DFC),
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

// ── Internal Badge Widget ──
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