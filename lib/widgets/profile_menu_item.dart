import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? badge;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.badge,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: c.border),
            borderRadius: BorderRadius.circular(16),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.red
                        : c.textSecondary,
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (badge != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius:
                          BorderRadius.circular(100),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (!isDestructive)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: c.textMuted,
                    size: 16,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}