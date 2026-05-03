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

  List<Color> _getCategoryGradient(String cat) {
    switch (cat.toLowerCase()) {
      case 'coding':   return [const Color(0xFF3B82F6), const Color(0xFF4F39F6)];
      case 'design':   return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
      case 'business': return [const Color(0xFFF97316), const Color(0xFFEF4444)];
      case 'langues':  return [const Color(0xFF10B981), const Color(0xFF059669)];
      default:         return [const Color(0xFF06B6D4), const Color(0xFF3B82F6)];
    }
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat.toLowerCase()) {
      case 'coding':   return Icons.code_rounded;
      case 'design':   return Icons.palette_rounded;
      case 'business': return Icons.business_center_rounded;
      case 'langues':  return Icons.translate_rounded;
      default:         return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = context.isDark;
    final gradient = _getCategoryGradient(category);
    final iconData = _getCategoryIcon(category);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: c.border, width: 1.5),
        boxShadow: isDark
            ? [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]
            : [
                BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 6)),
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(21)),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        width: double.infinity, height: 180, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(gradient, iconData),
                      )
                    : _buildPlaceholder(gradient, iconData),
              ),
              // Gradient overlay for readability
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
                  ),
                ),
              ),
              // Category badge
              Positioned(
                top: 14, left: 14,
                child: Row(children: [
                  _GradientBadge(label: category.toUpperCase(), gradient: gradient),
                  if (hasQuizGames) ...[
                    const SizedBox(width: 8),
                    _GradientBadge(label: '🎮 QUIZ', gradient: const [Color(0xFF10B981), Color(0xFF059669)]),
                  ],
                ]),
              ),
              // Bookmark button
              Positioned(
                top: 10, right: 10,
                child: GestureDetector(
                  onTap: onBookmark,
                  child: Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                    ),
                    child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              // Rating badge on image (bottom right)
              Positioned(
                bottom: 12, right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.star_rounded, color: Colors.white, size: 12),
                    const SizedBox(width: 3),
                    Text(rating, style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                  ]),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: c.textPrimary, fontSize: 17, fontFamily: 'Inter', fontWeight: FontWeight.w700, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  'By $instructor',
                  style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MetaChip(icon: Icons.access_time_rounded, label: duration, color: c.textSecondary),
                    const SizedBox(width: 10),
                    _MetaChip(icon: Icons.play_circle_outline_rounded, label: lessons, color: c.textSecondary),
                    const Spacer(),
                    GestureDetector(
                      onTap: onEnroll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                        ),
                        child: const Text('Enroll', style: TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
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

  Widget _buildPlaceholder(List<Color> gradient, IconData iconData) {
    return Container(
      height: 180,
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(child: Icon(iconData, size: 48, color: Colors.white.withOpacity(0.4))),
    );
  }
}

class _GradientBadge extends StatelessWidget {
  final String label;
  final List<Color> gradient;
  const _GradientBadge({required this.label, required this.gradient});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: gradient),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: gradient.first.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.6)),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 14, color: color),
    const SizedBox(width: 4),
    Text(label, style: TextStyle(color: color, fontSize: 12, fontFamily: 'Inter')),
  ]);
}
