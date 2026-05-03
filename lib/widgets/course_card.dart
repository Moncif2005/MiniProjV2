import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String instructor;
  final String rating;
  final String category;
  final String? imageUrl;
  final VoidCallback? onTap;

  const CourseCard({
    super.key,
    required this.title,
    required this.instructor,
    required this.rating,
    required this.category,
    this.imageUrl,
    this.onTap,
  });

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'coding':   return [const Color(0xFF3B82F6), const Color(0xFF4F39F6)];
      case 'design':   return [const Color(0xFF8B5CF6), const Color(0xFFEC4899)];
      case 'business': return [const Color(0xFFF97316), const Color(0xFFEF4444)];
      case 'langues':  return [const Color(0xFF10B981), const Color(0xFF059669)];
      default:         return [const Color(0xFF06B6D4), const Color(0xFF3B82F6)];
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
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
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final gradient = _getCategoryGradient(category);
    final iconData = _getCategoryIcon(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: c.border, width: 1.5),
          boxShadow: isDark
              ? [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / Gradient placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: hasImage
                    ? Image.network(imageUrl!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(gradient, iconData))
                    : _buildPlaceholder(gradient, iconData),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontFamily: 'Inter', fontWeight: FontWeight.w700, letterSpacing: 0.5),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, height: 1.2),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('By $instructor', style: TextStyle(color: c.textSecondary, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 13),
                        const SizedBox(width: 2),
                        Text(rating, style: TextStyle(color: c.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                      ]),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(List<Color> gradient, IconData iconData) {
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(child: Icon(iconData, size: 36, color: Colors.white.withOpacity(0.5))),
    );
  }
}
