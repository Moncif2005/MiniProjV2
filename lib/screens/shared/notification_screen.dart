import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/notifications_service.dart';
import '../../models/notification_model.dart';
import '../../widgets/notification_card.dart';
import '../../theme/app_colors.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _svc = NotificationsService();

  IconData _iconFor(NotifType type) {
    switch (type.category) {
      case 'job':
        return Icons.work_outline_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      case 'course':
        return Icons.menu_book_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorFor(NotifType type) {
    switch (type) {
      case NotifType.applicationAccepted:
        return const Color(0xFF16A34A);

      case NotifType.applicationRejected:
        return const Color(0xFFDC2626);

      case NotifType.applicationInterview:
        return const Color(0xFF7C3AED);

      case NotifType.applicationReviewing:
        return const Color(0xFFD97706);

      case NotifType.newApplicant:
        return AppColors.purple;

      // ── course ──
      case NotifType.courseEnrolled:
      case NotifType.lessonCompleted:
      case NotifType.courseCompleted:
      case NotifType.newStudentEnrolled:
      case NotifType.lessonAdded:
      case NotifType.courseRated:
        return AppColors.primary;

      // ── achievement ──
      case NotifType.streakAchievement:
      case NotifType.certificateEarned:
        return AppColors.orange;

      // ── job student ──
      case NotifType.applicationSent:
        return const Color(0xFF0891B2);

      case NotifType.offerPublished:
        return AppColors.primary;

      case NotifType.offerExpiring:
        return const Color(0xFFDC2626);

      case NotifType.system:
        return AppColors.primary;
    }
  }

  void _handleTap(NotificationModel n) {
    final payload = n.payload;
    if (payload == null) return;

    // ✅ 1. إشعارات الوظائف (للطالب والمسؤول)
    if (n.type.category == 'job') {
      
      // أ) إذا كان الإشعار لطالب (قبول/رفض/مقابلة)
      if (n.type == NotifType.applicationAccepted ||
          n.type == NotifType.applicationRejected ||
          n.type == NotifType.applicationInterview ||
          n.type == NotifType.applicationReviewing) {
        
        // نأخذه لشاشة "طلباتي" لي يرى التفاصيل
        // ملاحظة: يمكنك لاحقاً تمرير offerId لفتح تفاصيل الوظيفة مباشرة
        Navigator.pushNamed(context, '/applied-jobs');
      } 
      
      // ب) إذا كان الإشعار لمسؤول (متقدم جديد)
      else if (n.type == NotifType.newApplicant) {
        final offerId = payload['offerId'];
        final offerTitle = payload['offerTitle'] ?? 'Job';
        
        if (offerId != null) {
          // نأخذه لشاشة المتقدمين لهذه الوظيفة تحديداً
          Navigator.pushNamed(
            context,
            '/recruteur/applicants',
            arguments: {
              'offerId': offerId,
              'offerTitle': offerTitle,
            },
          );
        }
      }
    } 
    
    // ✅ 2. إشعارات الكورسات (للمعلم والطالب) - مستقبلاً
    else if (n.type.category == 'course') {
       // مثال: الذهاب للكورس المحدد
       // Navigator.pushNamed(context, '/course-details', arguments: payload['courseId']);
       Navigator.pushNamed(context, '/enseignant/home'); // مؤقتاً
    }
    
    // ✅ 3. إشعارات عامة
    else {
      // لا تفعل شيئاً أو ابقَ في شاشة الإشعارات
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 1. جلب الـ UID من UserProvider
    final userProvider = context.watch<UserProvider>();
    
    // ✅ 2. إذا كان الـ UID فارغاً في Provider، نجلبه مباشرة من FirebaseAuth
    final uid = userProvider.uid ?? FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('يرجى تسجيل الدخول أولاً')),
      );
    }

    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bg,
      body: StreamBuilder<List<NotificationModel>>(
        // ✅ 3. استخدام الـ UID المضمون
        stream: NotificationsService().streamNotifications(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text('حدث خطأ: ${snap.error}'));
          }

          final notifications = snap.data ?? [];
          final unread = notifications.where((n) => n.isUnread).length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 24,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (unread > 0)
                          Text(
                            '$unread unread',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                      ],
                    ),
                    if (unread > 0)
                      TextButton(
                        onPressed: () => NotificationsService().markAllRead(uid),
                        child: const Text(
                          'Mark all read',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined,
                                size: 56,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications yet',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                fontSize: 16,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: notifications.length,
                        itemBuilder: (_, i) {
                          final n = notifications[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Dismissible(
                              key: Key(n.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: const Icon(
                                  Icons.delete_outline_rounded,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                              onDismissed: (_) => NotificationsService().deleteNotification(uid, n.id),
                              child: NotificationCard(
                                notification: n,
                                onTap: () {
                                  if (n.isUnread) NotificationsService().markRead(uid, n.id);
                                  _handleTap(n); // يمكنك إعادة تفعيلها إذا أردت
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}