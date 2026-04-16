import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_colors.dart';

/// Reusable notification card — driven by [NotificationModel].
/// Supports all NotifTypes for étudiant, enseignant, and recruteur.
class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onDelete,
  });

  // ── Icon ──────────────────────────────────────────────────

  IconData get _icon {
    switch (notification.type) {
      // Course-family
      case NotifType.courseEnrolled:
      case NotifType.lessonCompleted:
      case NotifType.courseCompleted:
      case NotifType.newStudentEnrolled:
      case NotifType.lessonAdded:
        return Icons.menu_book_rounded;
      case NotifType.courseRated:
        return Icons.star_rounded;

      // Achievement-family
      case NotifType.streakAchievement:
        return Icons.local_fire_department_rounded;
      case NotifType.certificateEarned:
        return Icons.workspace_premium_rounded;

      // Job / Application — étudiant
      case NotifType.applicationSent:
        return Icons.send_rounded;
      case NotifType.applicationReviewing:
        return Icons.manage_search_rounded;
      case NotifType.applicationInterview:
        return Icons.calendar_month_rounded;
      case NotifType.applicationAccepted:
        return Icons.check_circle_rounded;
      case NotifType.applicationRejected:
        return Icons.cancel_rounded;

      // Job / Application — recruteur
      case NotifType.newApplicant:
        return Icons.person_add_rounded;
      case NotifType.offerPublished:
        return Icons.rocket_launch_rounded;
      case NotifType.offerExpiring:
        return Icons.warning_amber_rounded;

      // System
      case NotifType.system:
        return Icons.notifications_rounded;
    }
  }

  // ── Colours ───────────────────────────────────────────────

  Color get _iconColor {
    switch (notification.type) {
      case NotifType.courseEnrolled:
      case NotifType.lessonCompleted:
      case NotifType.courseCompleted:
      case NotifType.newStudentEnrolled:
      case NotifType.lessonAdded:
      case NotifType.offerPublished:
        return AppColors.primary;

      case NotifType.streakAchievement:
      case NotifType.courseRated:
        return AppColors.orange;

      case NotifType.certificateEarned:
      case NotifType.newApplicant:
        return AppColors.purple;

      case NotifType.applicationSent:
        return const Color(0xFF0891B2);   // cyan
      case NotifType.applicationReviewing:
        return const Color(0xFFD97706);   // amber
      case NotifType.applicationInterview:
        return const Color(0xFF7C3AED);   // violet
      case NotifType.applicationAccepted:
        return const Color(0xFF16A34A);   // green
      case NotifType.applicationRejected:
      case NotifType.offerExpiring:
        return const Color(0xFFDC2626);   // red

      case NotifType.system:
        return AppColors.primary;
    }
  }

  Color get _iconBg => _iconColor.withOpacity(0.12);

  Color _borderColor(ThemeColors c) => notification.isUnread
      ? AppColors.primaryLight
      : c.border;

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: c.surface,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1.24, color: _borderColor(c)),
            borderRadius: BorderRadius.circular(24),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 2,
              offset: Offset(0, 1),
              spreadRadius: -1,
            ),
            BoxShadow(
              color: Color(0x14000000),
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
              width: 48, height: 48,
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

                  // Title + unread dot
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            color: notification.isUnread
                                ? c.textPrimary
                                : c.textSecondary,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (notification.isUnread) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Body
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'Inter',
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        color: c.textMuted,
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.timeAgo,
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 10,
                          fontFamily: 'Inter',
                        ),
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
}
