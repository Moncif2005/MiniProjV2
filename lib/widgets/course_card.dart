import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

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

  Color _getCategoryColor(String category, bool isDark) {
    switch (category.toLowerCase()) {
      case 'coding':   return AppColors.primary.withOpacity(isDark ? 0.20 : 0.12);
      case 'design':   return Colors.purple.withOpacity(isDark ? 0.20 : 0.12);
      case 'business': return Colors.orange.withOpacity(isDark ? 0.20 : 0.12);
      default:         return AppColors.primary.withOpacity(isDark ? 0.20 : 0.12);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'coding': return Icons.code_rounded;
      case 'design': return Icons.palette_rounded;
      case 'business': return Icons.business_center_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    final bgColor = _getCategoryColor(category, context.isDark);
    final iconData = _getCategoryIcon(category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الجزء العلوي: الصورة أو الخلفية الملونة
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: hasImage
                    ? Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder(bgColor, iconData, c))
                    : _buildPlaceholder(bgColor, iconData, c),
              ),
            ),
            
            // الجزء السفلي: النصوص (مضغوط ومرن)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // تقليل الهامش العمودي
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category,
                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, height: 1.1),
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'By $instructor',
                          style: TextStyle(color: c.textSecondary, fontSize: 11),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 2),
                          Text(rating, style: TextStyle(color: c.textPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
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

  Widget _buildPlaceholder(Color bgColor, IconData iconData, ThemeColors c) {
    return Container(
      color: bgColor,
      child: Center(child: Icon(iconData, size: 32, color: c.textPrimary.withOpacity(0.3))),
    );
  }
}