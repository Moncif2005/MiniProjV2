import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavBarItem> items; // ✅ قائمة مخصصة للأيقونات

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: c.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
              (index) => _NavItem(
                item: items[index],
                isSelected: currentIndex == index,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── نموذج العنصر ──
class NavBarItem {
  final IconData icon;
  final String label;
  
  const NavBarItem({
    required this.icon,
    required this.label,
  });
}

// ── عنصر التنقل ──
class _NavItem extends StatelessWidget {
  final NavBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isSelected ? AppColors.primary : c.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : c.textMuted,
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}