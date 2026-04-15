import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/notifications_service.dart';
import '../../models/notification_model.dart';
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

    switch (n.type) {
      case NotifType.applicationAccepted:
      case NotifType.applicationRejected:
      case NotifType.applicationInterview:
      case NotifType.applicationReviewing:
        Navigator.pushNamed(
          context,
          '/applicationDetails',
          arguments: payload['applicationId'],
        );
        break;

      case NotifType.newApplicant:
        Navigator.pushNamed(
          context,
          '/recruteur/applicants',
          arguments: {
            'offerId': payload['offerId'],
          },
        );
        break;

      default:
        // لا تفعل شيء → مهم جداً
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<UserProvider>().uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Non connecté')),
      );
    }

    return Scaffold(
      body: StreamBuilder<List<NotificationModel>>(
        stream: _svc.streamNotifications(uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                    Text("Notifications ($unread)"),
                    TextButton(
                      onPressed: () => _svc.markAllRead(uid),
                      child: const Text("Tout lu"),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: notifications.isEmpty
                    ? const Center(child: Text("Aucune notification"))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (_, i) {
                          final n = notifications[i];

                          return Dismissible(
                            key: Key(n.id),
                            onDismissed: (_) =>
                                _svc.deleteNotification(uid, n.id),
                            child: ListTile(
                              onTap: () {
                                if (n.isUnread) {
                                  _svc.markRead(uid, n.id);
                                }
                                _handleTap(n);
                              },
                              leading: CircleAvatar(
                                backgroundColor:
                                    _colorFor(n.type).withOpacity(0.15),
                                child: Icon(
                                  _iconFor(n.type),
                                  color: _colorFor(n.type),
                                ),
                              ),
                              title: Text(n.title),
                              subtitle: Text(n.body),
                              trailing: Text(n.timeAgo),
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