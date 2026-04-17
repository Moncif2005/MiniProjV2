import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'notifications_service.dart';

class AppliedJobsService {
  final _db = FirebaseFirestore.instance;
  final notif = NotificationsService();

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('applications');

  // ─────────────────────────────
  // APPLY
  // ─────────────────────────────

  Future<String?> apply({
    required String uid,
    required String offerId,
    required String offerTitle,
    required String company,
    required String companyInitial,
    required int companyBgColor,
    required int companyColor,
    required String location,
    required String jobType,
    required String salary,
  }) async {
    try {
      // check duplicate
      final existing = await _col
          .where('applicantId', isEqualTo: uid)
          .where('offerId', isEqualTo: offerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) return null;

      final ref = await _col.add({
        'applicantId': uid,
        'offerId': offerId,
        'offerTitle': offerTitle,
        'company': company,
        'companyInitial': companyInitial,
        'companyBgColor': companyBgColor,
        'companyColor': companyColor,
        'location': location,
        'jobType': jobType,
        'salary': salary,
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'viewCount': 0,
      });

      // get offer safely
      final offerDoc = await _db.collection('offers').doc(offerId).get();
      final recruiterId = offerDoc.data()?['recruiterId'];
      if (recruiterId == null) return ref.id;

      // get user safely
      final userDoc = await _db.collection('users').doc(uid).get();
      final name = userDoc.data()?['name'] ?? 'User';

      // notify recruiter
      await notif.notifyNewApplicant(
  recruteurUid: recruiterId,  // ✅ نمرر القيمة الصحيحة
        applicantName: name,
        offerTitle: offerTitle,
        applicationId: ref.id,
        offerId: offerId,
      );

      return ref.id;
    } catch (e) {
      debugPrint('❌ apply: $e');
      return null;
    }
  }

  // ─────────────────────────────
  // UPDATE STATUS
  // ─────────────────────────────

  Future<void> updateStatus({
    required String applicationId,
    required String status,
    String? message,
  }) async {
    try {
      await _col.doc(applicationId).update({
        'status': status,
        if (message != null) 'statusMessage': message,
      });

      final doc = await _col.doc(applicationId).get();
      final data = doc.data();

      if (data == null) return;

      await notif.notifyStatus(
        uid: data['applicantId'],
        status: status,
        offerTitle: data['offerTitle'],
        company: data['company'],
        applicationId: applicationId,
      );
    } catch (e) {
      debugPrint('❌ updateStatus: $e');
    }
  }
}