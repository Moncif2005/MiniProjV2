import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class ContinueLearningCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress; // نسبة من 0 إلى 100
  final VoidCallback? onTap;

  const ContinueLearningCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                color: c.textSecondary,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            
            // شريط التقدم
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: progress / 100, // تحويل النسبة المئوية إلى قيمة بين 0 و 1
                minHeight: 8,
                backgroundColor: c.iconBg,
                valueColor: AlwaysStoppedAnimation(AppColors.green),
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${progress.toInt()}% Complete',
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}