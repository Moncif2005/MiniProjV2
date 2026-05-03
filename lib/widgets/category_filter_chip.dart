import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? accentColor;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? accent
              : (isDark ? AppColors.darkSurface2 : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? accent
                : (isDark ? AppColors.darkBorder : const Color(0xFFE8EEFF)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: accent.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4), spreadRadius: -2)]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : const Color(0xFF5B6A8A)),
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: isSelected ? 0.3 : 0,
          ),
        ),
      ),
    );
  }
}
