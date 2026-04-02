import 'package:flutter/material.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0xFF155DFC) : Colors.white,
          shape: StadiumBorder(
            side: BorderSide(
              width: 1.24,
              color: isSelected
                  ? const Color(0xFF155DFC)
                  : const Color(0xFFF5F5F5),
            ),
          ),
          shadows: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0xFFDBEAFE),
                    blurRadius: 6,
                    offset: Offset(0, 4),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0xFFDBEAFE),
                    blurRadius: 15,
                    offset: Offset(0, 10),
                    spreadRadius: -3,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF737373),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}