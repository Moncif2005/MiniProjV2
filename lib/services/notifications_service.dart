import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final _db = FirebaseFirestore.instance;

  // ── Stream of notifications for a user ──
  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromDoc).toList());
  }

  // ✅ Stream for unread count
  Stream<int> streamUnreadCount(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isUnread', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  // ── Mark single notification as read ──
  Future<void> markRead(String uid, String notifId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .update({'isUnread': false});
  }

  // ── Mark all as read ──
  Future<void> markAllRead(String uid) async {
    final batch = _db.batch();
    final snap = await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .where('isUnread', isEqualTo: true)
        .get();
    
    for (var doc in snap.docs) {
      batch.update(doc.reference, {'isUnread': false});
    }
    await batch.commit();
  }

  // ── Delete notification ──
  Future<void> deleteNotification(String uid, String notifId) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notifId)
        .delete();
  }

  // ✅ ✅ ✅ دوال إنشاء الإشعارات (المفقودة سابقاً) ✅ ✅ ✅

  Future<void> notifyNewApplicant({
    required String recruteurUid,
    required String applicantName,
    required String offerTitle,
    required String applicationId,
    required String offerId,
  }) async {
    await _db.collection('users').doc(recruteurUid).collection('notifications').add({
      'title': 'New Application Received',
      'body': '$applicantName applied to "$offerTitle"',
      'type': NotifType.newApplicant.key,
      'isUnread': true,
      'createdAt': FieldValue.serverTimestamp(),
      'payload': {
        'applicationId': applicationId,
        'offerId': offerId,
        'applicantName': applicantName,
      },
    });
  }

  Future<void> notifyStatus({
    required String uid,
    required String status,
    required String offerTitle,
    required String company,
    required String applicationId,
  }) async {
    String title, body;
    NotifType type;

    switch (status) {
      case 'reviewing':
        title = 'Application Under Review';
        body = 'Your application for "$offerTitle" is being reviewed';
        type = NotifType.applicationReviewing;
        break;
      case 'interview':
        title = 'Interview Invitation';
        body = 'You\'ve been invited to interview for "$offerTitle" at $company';
        type = NotifType.applicationInterview;
        break;
      case 'accepted':
        title = 'Application Accepted! 🎉';
        body = 'Congratulations! Your application for "$offerTitle" was accepted';
        type = NotifType.applicationAccepted;
        break;
      case 'rejected':
        title = 'Application Update';
        body = 'Your application for "$offerTitle" was not selected this time';
        type = NotifType.applicationRejected;
        break;
      default:
        return;
    }

    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': title,
      'body': body,
      'type': type.key,
      'isUnread': true,
      'createdAt': FieldValue.serverTimestamp(),
      'payload': {
        'applicationId': applicationId,
        'offerTitle': offerTitle,
        'company': company,
        'status': status,
      },
    });
  }

  // ✅ دوال إضافية مفيدة
  Future<void> notifyCourseEnrolled({
    required String uid,
    required String courseTitle,
  }) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': 'Enrolled in Course',
      'body': 'You successfully enrolled in "$courseTitle"',
      'type': NotifType.courseEnrolled.key,
      'isUnread': true,
      'createdAt': FieldValue.serverTimestamp(),
      'payload': {'courseTitle': courseTitle},
    });
  }

  Future<void> notifyCertificateEarned({
    required String uid,
    required String certificateTitle,
  }) async {
    await _db.collection('users').doc(uid).collection('notifications').add({
      'title': 'Certificate Earned! 🏆',
      'body': 'Congratulations! You earned "$certificateTitle"',
      'type': NotifType.certificateEarned.key,
      'isUnread': true,
      'createdAt': FieldValue.serverTimestamp(),
      'payload': {'certificateTitle': certificateTitle},
    });
  }
}