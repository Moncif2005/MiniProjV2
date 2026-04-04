import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /users/{uid}/notifications/{notifId}
///   - title: String
///   - body: String
///   - type: String   ('course' | 'job' | 'achievement' | 'system')
///   - isUnread: bool
///   - createdAt: Timestamp
///   - payload: Map?  (optional: courseId, offerId, etc.)

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  bool isUnread;
  final Timestamp createdAt;
  final Map<String, dynamic>? payload;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isUnread,
    required this.createdAt,
    this.payload,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id:        doc.id,
      title:     d['title']     ?? '',
      body:      d['body']      ?? '',
      type:      d['type']      ?? 'system',
      isUnread:  d['isUnread']  ?? true,
      createdAt: d['createdAt'] ?? Timestamp.now(),
      payload:   d['payload']   as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
    'title':     title,
    'body':      body,
    'type':      type,
    'isUnread':  isUnread,
    'createdAt': createdAt,
    if (payload != null) 'payload': payload,
  };

  /// e.g. "2 min ago", "1h ago", "Yesterday", "3d ago"
  String get timeAgo {
    final diff = DateTime.now().difference(createdAt.toDate());
    if (diff.inMinutes < 60)  return '${diff.inMinutes} min ago';
    if (diff.inHours   < 24)  return '${diff.inHours}h ago';
    if (diff.inDays    == 1)  return 'Yesterday';
    if (diff.inDays    < 7)   return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class NotificationsService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  // ── Read ─────────────────────────────────────────────────

  /// Real-time stream of all notifications for a user, newest first
  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromDoc).toList());
  }

  /// Unread count stream (for badge)
  Stream<int> streamUnreadCount(String uid) {
    return _col(uid)
        .where('isUnread', isEqualTo: true)
        .snapshots()
        .map((s) => s.size);
  }

  // ── Write ────────────────────────────────────────────────

  /// Mark a single notification as read
  Future<void> markRead(String uid, String notifId) async {
    try {
      await _col(uid).doc(notifId).update({'isUnread': false});
    } catch (e) {
      debugPrint('❌ NotificationsService.markRead: $e');
    }
  }

  /// Mark ALL notifications as read (batch)
  Future<void> markAllRead(String uid) async {
    try {
      final snap = await _col(uid).where('isUnread', isEqualTo: true).get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isUnread': false});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('❌ NotificationsService.markAllRead: $e');
    }
  }

  /// Push a new notification to a user
  Future<void> pushNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? payload,
  }) async {
    try {
      await _col(uid).add({
        'title':     title,
        'body':      body,
        'type':      type,
        'isUnread':  true,
        'createdAt': FieldValue.serverTimestamp(),
        if (payload != null) 'payload': payload,
      });
    } catch (e) {
      debugPrint('❌ NotificationsService.pushNotification: $e');
    }
  }

  /// Delete a single notification
  Future<void> deleteNotification(String uid, String notifId) async {
    try {
      await _col(uid).doc(notifId).delete();
    } catch (e) {
      debugPrint('❌ NotificationsService.deleteNotification: $e');
    }
  }
}
