import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconPath;

  const SocialButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconPath != null)
              Image.asset(
                iconPath!,
                width: 20,
                height: 20,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.image_not_supported_outlined,
                  size: 20,
                  color: c.textSecondary,
                ),
              )
            else if (icon != null)
              Icon(icon, size: 22, color: c.textSecondary),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}