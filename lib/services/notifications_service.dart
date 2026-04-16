import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  // ─────────────────────────────
  // STREAM
  // ─────────────────────────────

  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(NotificationModel.fromDoc).toList());
  }

  // ─────────────────────────────
  // CORE PUSH
  // ─────────────────────────────

  // ── Fetch the user's FCM token from Firestore ────────────────────────────
  Future<String?> _getToken(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['fcmToken'] as String?;
  }

  Future<void> _push({
    required String uid,
    required String title,
    required String body,
    required NotifType type,
    Map<String, dynamic>? payload,
  }) async {
    // Resolve FCM token (may be null if user logged out or never granted permission)
    final token = await _getToken(uid);

    await _col(uid).add({
      'title': title,
      'body': body,
      'type': type.key,
      'isUnread': true,
      'createdAt': FieldValue.serverTimestamp(),
      if (payload != null) 'payload': payload,
      // ── FCM fields (read by Cloud Function to send push) ──
      if (token != null) 'fcmToken': token,
      'fcmSent': false,
    });
  }

  // ───────── RECRUITER ─────────

  Future<void> notifyNewApplicant({
    required String recruteurUid,
    required String applicantName,
    required String offerTitle,
    required String applicationId,
    required String offerId,
  }) {
    return _push(
      uid: recruteurUid,
      title: "Nouvelle candidature 📩",
      body: "$applicantName a postulé pour $offerTitle",
      type: NotifType.newApplicant,
      payload: {
        'applicationId': applicationId,
        'offerId': offerId,
      },
    );
  }

  // ───────── STUDENT STATUS ─────────

  Future<void> notifyStatus({
    required String uid,
    required String status,
    required String offerTitle,
    required String company,
    required String applicationId,
  }) {
    switch (status) {
      case 'reviewing':
        return _push(
          uid: uid,
          title: "En cours d'examen",
          body: "$company examine $offerTitle",
          type: NotifType.applicationReviewing,
          payload: {'applicationId': applicationId},
        );

      case 'interview':
        return _push(
          uid: uid,
          title: "Entretien 📅",
          body: "$company vous invite",
          type: NotifType.applicationInterview,
          payload: {'applicationId': applicationId},
        );

      case 'accepted':
        return _push(
          uid: uid,
          title: "Accepté 🎉",
          body: "$company a accepté votre candidature",
          type: NotifType.applicationAccepted,
          payload: {'applicationId': applicationId},
        );

      case 'rejected':
        return _push(
          uid: uid,
          title: "Refusé",
          body: "$company a refusé votre candidature",
          type: NotifType.applicationRejected,
          payload: {'applicationId': applicationId},
        );

      default:
        return Future.value();
    }
  }

  // ─────────────────────────────
  // READ / DELETE
  // ─────────────────────────────

  Future<void> markRead(String uid, String id) {
    return _col(uid).doc(id).update({'isUnread': false});
  }

  Future<void> markAllRead(String uid) async {
    final snap =
        await _col(uid).where('isUnread', isEqualTo: true).get();

    await Future.wait(
      snap.docs.map((d) => d.reference.update({'isUnread': false})),
    );
  }

  Future<void> deleteNotification(String uid, String id) {
    return _col(uid).doc(id).delete();
  }
}