import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../services/notifications_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _service = NotificationsService();
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  Future<void> _markAllRead() async {
    final uid = _uid;
    if (uid == null) return;
    await _service.markAllRead(uid);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('All notifications marked as read'),
      backgroundColor: AppColors.primary,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _markRead(String notifId) async {
    final uid = _uid;
    if (uid != null) await _service.markRead(uid, notifId);
  }

  Future<void> _delete(String notifId) async {
    final uid = _uid;
    if (uid != null) await _service.deleteNotification(uid, notifId);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'job':         return Icons.work_outline_rounded;
      case 'achievement': return Icons.emoji_events_rounded;
      default:            return Icons.menu_book_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'job':         return AppColors.purple;
      case 'achievement': return AppColors.orange;
      default:            return AppColors.primary;
    }
  }

  Color _bgForType(String type) {
    switch (type) {
      case 'job':         return AppColors.purpleLight;
      case 'achievement': return const Color(0xFFFFEDD4);
      default:            return AppColors.primaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c   = context.colors;
    final uid = _uid;

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
                Row(children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: c.bg, borderRadius: BorderRadius.circular(14)),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: c.textPrimary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // ── Unread count from stream ──
                  uid != null
                      ? StreamBuilder<int>(
                          stream: _service.streamUnreadCount(uid),
                          builder: (context, snap) {
                            final unread = snap.data ?? 0;
                            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Notifications', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                              Text('$unread non lue${unread > 1 ? 's' : ''}', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Inter')),
                            ]);
                          },
                        )
                      : Text('Notifications', style: TextStyle(color: c.textPrimary, fontSize: 18, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ]),
                GestureDetector(
                  onTap: _markAllRead,
                  child: Text('Tout lire',
                      style: TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // ── List ──
          Expanded(
            child: uid == null
                ? Center(child: Text('Non connecté', style: TextStyle(color: c.textMuted)))
                : StreamBuilder<List<NotificationModel>>(
                    stream: _service.streamNotifications(uid),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snap.hasError) {
                        return Center(child: Text('Erreur', style: TextStyle(color: c.textMuted)));
                      }
                      final notifications = snap.data ?? [];

                      if (notifications.isEmpty) {
                        return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Icon(Icons.notifications_off_outlined, color: c.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text('Aucune notification', style: TextStyle(color: c.textMuted, fontSize: 16, fontFamily: 'Inter')),
                        ]));
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final n        = notifications[index];
                          final isUnread = n.isUnread;
                          final type     = n.type;

                          return Dismissible(
                            key: Key(n.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => _delete(n.id),
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                            ),
                            child: GestureDetector(
                              onTap: () => isUnread ? _markRead(n.id) : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: ShapeDecoration(
                                  color: isUnread
                                      ? (context.isDark ? const Color(0xFF1A2A4A) : const Color(0xFFEFF6FF))
                                      : c.surface,
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
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                          Flexible(child: Text(n.title,
                                              style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w700))),
                                          if (isUnread)
                                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                                        ]),
                                        const SizedBox(height: 4),
                                        Text(n.body, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter')),
                                        const SizedBox(height: 6),
                                        Text(n.timeAgo, style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Inter')),
                                      ]),
                                    ),
                                  ],
                                ),
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
