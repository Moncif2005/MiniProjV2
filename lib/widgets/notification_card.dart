import 'package:flutter/material.dart';

enum NotificationType { course, job, achievement }

class NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final NotificationType type;
  final bool isUnread;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = false,
    this.onTap,
  });

  // ── Icon & colors per type ──
  IconData get _icon {
    switch (type) {
      case NotificationType.course:      return Icons.menu_book_rounded;
      case NotificationType.job:         return Icons.work_outline_rounded;
      case NotificationType.achievement: return Icons.emoji_events_rounded;
    }
  }

  Color get _iconBg {
    switch (type) {
      case NotificationType.course:      return const Color(0xFFEFF6FF);
      case NotificationType.job:         return const Color(0xFFF0FDF4);
      case NotificationType.achievement: return const Color(0xFFFAF5FF);
    }
  }

  Color get _iconColor {
    switch (type) {
      case NotificationType.course:      return const Color(0xFF155DFC);
      case NotificationType.job:         return const Color(0xFF00A63E);
      case NotificationType.achievement: return const Color(0xFF9810FA);
    }
  }

  Color get _borderColor {
    return isUnread
        ? const Color(0xFFDBEAFE)
        : const Color(0xFFF5F5F5);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: _borderColor),
            borderRadius: BorderRadius.circular(24),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Icon Box ──
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(_icon, color: _iconColor, size: 24),
            ),
            const SizedBox(width: 16),

            // ── Content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Title + Time ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isUnread
                                ? const Color(0xFF171717)
                                : const Color(0xFF525252),
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFFA1A1A1),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            time,
                            style: const TextStyle(
                              color: Color(0xFFA1A1A1),
                              fontSize: 10,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // ── Message ──
                  Text(
                    message,
                    style: const TextStyle(
                      color: Color(0xFF737373),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.63,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Unread Blue Dot ──
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF155DFC),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}