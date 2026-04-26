import 'package:flutter/material.dart';

enum LessonStatus { completed, current, locked }

class LessonItem extends StatelessWidget {
  final int number;
  final String title;
  final String duration;
  final LessonStatus status;
  final VoidCallback? onTap;

  const LessonItem({
    super.key,
    required this.number,
    required this.title,
    required this.duration,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive  = status == LessonStatus.current;
    final isLocked  = status == LessonStatus.locked;

    // ── Colors per state ──
    final bgColor = isActive
        ? const Color(0xFFF0FDF4)
        : const Color(0xFFFAFAFA);

    final borderColor = isActive
        ? const Color(0xFF00C950)
        : Colors.transparent;

    final iconBg = isActive
        ? const Color(0xFFDBEAFE)
        : isLocked
            ? const Color(0xFFE5E5E5)
            : const Color(0xFF00A63E);

    final titleColor = isLocked
        ? const Color(0xFFA1A1A1)
        : const Color(0xFF171717);

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: ShapeDecoration(
          color: bgColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: borderColor),
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: SizedBox(
          height: isActive ? 74 : 72,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ── Icon / Number Box ──
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isActive
                      ? Text(
                          '$number',
                          style: const TextStyle(
                            color: Color(0xFF155DFC),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      : isLocked
                          ? const Icon(Icons.lock_outline,
                              color: Color(0xFFA1A1A1), size: 20)
                          : const Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),

              // ── Title & Duration ──
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duration,
                      style: const TextStyle(
                        color: Color(0xFF737373),
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Arrow for active ──
              if (isActive)
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF00A63E),
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }
}