import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../l10n/app_localizations.dart';
import '../../services/notifications_service.dart';
import '../../models/notification_model.dart';
// ✅ استيراد الشاشات التي سننتقل إليها
import '../recruteur/recruiter_applicants_screen.dart'; // للأدمن/المسؤول
import '../shared/applied_jobs_screen.dart'; // للطالب/المتعلم
import '../shared/course_details_screen.dart'; // للكورسات

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationsService = NotificationsService();
  final _userUid = FirebaseAuth.instance.currentUser?.uid;

  // ✅✅✅ الدالة المصححة نهائياً: معالجة الضغط على الإشعار ✅✅✅
  void _handleNotificationTap(NotificationModel n) {
    // 1. تعليم الإشعار كمقروء أولاً
    if (n.isUnread && _userUid != null) {
      _notificationsService.markRead(_userUid!, n.id);
    }

    // 2. استخراج البيانات من payload
    final payload = n.payload ?? {};
    final offerId = payload['offerId'] as String?;
    final applicationId = payload['applicationId'] as String?;
    final courseId = payload['courseId'] as String?;

    // 3. التوجيه حسب نوع الإشعار
    switch (n.type) {
      // ── إشعارات الوظائف ──
      
      // ✅ للمعلم/المسؤول: إشعار بوجود متقدم جديد
      case NotifType.newApplicant:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const RecruiterApplicantsScreen(),
          ),
        );
        break;

      // ✅ للطالب/المتقدم (معلم أو متعلم): إشعار بتحديث حالة الطلب
      // ✅✅✅ التصحيح: استخدام المسار الصحيح '/applied-jobs' ✅✅✅
      case NotifType.applicationAccepted:
      case NotifType.applicationRejected:
      case NotifType.applicationInterview:
      case NotifType.applicationReviewing:
      case NotifType.applicationSent:
        // ✅ استخدام pushNamed مع المسار الصحيح
        Navigator.pushNamed(context, '/applied-jobs');
        break;

      // ── إشعارات الكورسات ──
      
      // ✅ للطالب: إشعار بكورس جديد أو درس مضاف
      case NotifType.courseEnrolled:
      case NotifType.lessonAdded:
      case NotifType.courseCompleted:
        if (courseId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseDetailsScreen(courseId: courseId),
            ),
          );
        }
        break;

      // ✅ للطالب: إشعار بإنجاز أو شهادة
      case NotifType.certificateEarned:
      case NotifType.streakAchievement:
        // ✅ تأكد من المسار الصحيح للبروفايل
        Navigator.pushNamed(context, '/profile');
        break;

      // ── الإشعارات الأخرى ──
      default:
        debugPrint('🔔 No navigation defined for type: ${n.type}');
    }
  }

  // ✅ دالة مساعدة لتحديد الأيقونة حسب النوع
  IconData _iconForType(NotifType type) {
    switch (type.category) {
      case 'job': return Icons.work_outline_rounded;
      case 'achievement': return Icons.emoji_events_rounded;
      default: return Icons.menu_book_rounded;
    }
  }

  // ✅ دالة مساعدة لتحديد اللون حسب النوع
  Color _colorForType(NotifType type) {
    switch (type.category) {
      case 'job': return AppColors.purple;
      case 'achievement': return AppColors.orange;
      default: return AppColors.primary;
    }
  }

  // ✅ دالة مساعدة لتحديد لون الخلفية حسب النوع
  Color _bgForType(NotifType type) {
    switch (type.category) {
      case 'job': return AppColors.purpleLight;
      case 'achievement': return const Color(0xFFFFEDD4);
      default: return AppColors.primaryLight;
    }
  }

  // ✅ تحديد لون الخلفية للإشعار غير المقروء
  Color _bgForUnread(bool isUnread, bool isDark) {
    if (!isUnread) return Theme.of(context).cardColor;
    return isDark ? const Color(0xFF1A2A4A) : const Color(0xFFEFF6FF);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Column(
        children: [
          // ── App Bar ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
            decoration: BoxDecoration(
              color: c.surface,
              border: Border(bottom: BorderSide(color: c.border, width: 1.24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                        child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).notificationsTitle,
                          style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                        ),
                        StreamBuilder<int>(
                          stream: _userUid != null ? _notificationsService.streamUnreadCount(_userUid!) : Stream.value(0),
                          builder: (context, snap) {
                            final count = snap.data ?? 0;
                            return Text(
                              '$count ${AppLocalizations.of(context).allRead}',
                              style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter'),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                StreamBuilder<int>(
                  stream: _userUid != null ? _notificationsService.streamUnreadCount(_userUid!) : Stream.value(0),
                  builder: (context, snap) {
                    final hasUnread = (snap.data ?? 0) > 0;
                    return GestureDetector(
                      onTap: hasUnread && _userUid != null ? () => _notificationsService.markAllRead(_userUid!) : null,
                      child: Text(
                        AppLocalizations.of(context).markAllRead,
                        style: TextStyle(
                          color: hasUnread ? AppColors.primary : c.textMuted,
                          fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── List (Real Data from Firestore) ──
          Expanded(
            child: _userUid == null
                ? Center(child: Text(AppLocalizations.of(context).pleaseSignIn, style: TextStyle(color: c.textMuted)))
                : StreamBuilder<List<NotificationModel>>(
                    stream: _notificationsService.streamNotifications(_userUid!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: AppColors.red),
                              const SizedBox(height: 12),
                              Text('Error loading notifications', style: TextStyle(color: c.textMuted)),
                            ],
                          ),
                        );
                      }

                      final notifications = snapshot.data ?? [];
                      if (notifications.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.notifications_none_rounded, size: 48, color: c.textMuted),
                              const SizedBox(height: 12),
                              Text(AppLocalizations.of(context).allCaughtUp, style: TextStyle(color: c.textMuted, fontFamily: 'Inter', fontSize: 15)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          final isUnread = n.isUnread;
                          final type = n.type;

                          return GestureDetector(
                            // ✅✅✅ استخدام الدالة الجديدة للتوجيه ✅✅✅
                            onTap: () => _handleNotificationTap(n),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: ShapeDecoration(
                                color: _bgForUnread(isUnread, context.isDark),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(width: 1.24, color: isUnread ? AppColors.primaryLight : c.border),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(color: _bgForType(type), borderRadius: BorderRadius.circular(14)),
                                    child: Icon(_iconForType(type), color: _colorForType(type), size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                n.title,
                                                style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            if (isUnread)
                                              Container(
                                                width: 8, height: 8,
                                                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          n.body,
                                          style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter'),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          n.timeAgo,
                                          style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}