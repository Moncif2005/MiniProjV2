import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /applications/{applicationId}
///   - applicantId: String         (uid of student)
///   - offerId: String
///   - offerTitle: String
///   - company: String
///   - companyInitial: String
///   - companyBgColor: int
///   - companyColor: int
///   - location: String
///   - jobType: String
///   - salary: String
///   - appliedAt: Timestamp
///   - status: String   ('pending' | 'reviewing' | 'interview' | 'accepted' | 'rejected')
///   - statusMessage: String?  (recruiter note)
///   - viewCount: int          (how many times recruiter viewed)
///
/// Index needed in Firestore:
///   Collection: applications
///   Fields: applicantId ASC, appliedAt DESC

enum ApplicationStatus { pending, reviewing, interview, accepted, rejected }

class ApplicationModel {
  final String id;
  final String applicantId;
  final String offerId;
  final String offerTitle;
  final String company;
  final String companyInitial;
  final int companyBgColor;
  final int companyColor;
  final String location;
  final String jobType;
  final String salary;
  final Timestamp appliedAt;
  final ApplicationStatus status;
  final String? statusMessage;
  final int viewCount;

  ApplicationModel({
    required this.id,
    required this.applicantId,
    required this.offerId,
    required this.offerTitle,
    required this.company,
    required this.companyInitial,
    required this.companyBgColor,
    required this.companyColor,
    required this.location,
    required this.jobType,
    required this.salary,
    required this.appliedAt,
    required this.status,
    this.statusMessage,
    required this.viewCount,
  });

  factory ApplicationModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ApplicationModel(
      id:              doc.id,
      applicantId:     d['applicantId']    ?? '',
      offerId:         d['offerId']        ?? '',
      offerTitle:      d['offerTitle']     ?? '',
      company:         d['company']        ?? '',
      companyInitial:  d['companyInitial'] ?? '',
      companyBgColor:  d['companyBgColor'] ?? 0xFFE0E7FF,
      companyColor:    d['companyColor']   ?? 0xFF4F39F6,
      location:        d['location']       ?? '',
      jobType:         d['jobType']        ?? '',
      salary:          d['salary']         ?? '',
      appliedAt:       d['appliedAt']      ?? Timestamp.now(),
      status:          _parseStatus(d['status']),
      statusMessage:   d['statusMessage'],
      viewCount:       d['viewCount']      ?? 0,
    );
  }

  static ApplicationStatus _parseStatus(String? s) {
    switch (s) {
      case 'reviewing': return ApplicationStatus.reviewing;
      case 'interview': return ApplicationStatus.interview;
      case 'accepted':  return ApplicationStatus.accepted;
      case 'rejected':  return ApplicationStatus.rejected;
      default:          return ApplicationStatus.pending;
    }
  }

  static String statusToString(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.reviewing: return 'reviewing';
      case ApplicationStatus.interview: return 'interview';
      case ApplicationStatus.accepted:  return 'accepted';
      case ApplicationStatus.rejected:  return 'rejected';
      case ApplicationStatus.pending:   return 'pending';
    }
  }

  Map<String, dynamic> toMap() => {
    'applicantId':    applicantId,
    'offerId':        offerId,
    'offerTitle':     offerTitle,
    'company':        company,
    'companyInitial': companyInitial,
    'companyBgColor': companyBgColor,
    'companyColor':   companyColor,
    'location':       location,
    'jobType':        jobType,
    'salary':         salary,
    'appliedAt':      appliedAt,
    'status':         statusToString(status),
    if (statusMessage != null) 'statusMessage': statusMessage,
    'viewCount':      viewCount,
  };

  String get appliedAgo {
    final diff = DateTime.now().difference(appliedAt.toDate());
    if (diff.inHours < 24)  return '${diff.inHours}h ago';
    if (diff.inDays  < 7)   return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class AppliedJobsService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('applications');

  // ── Read ─────────────────────────────────────────────────

  /// Real-time stream of all applications by a student, newest first
  Stream<List<ApplicationModel>> streamApplications(String uid) {
    return _col
        .where('applicantId', isEqualTo: uid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(ApplicationModel.fromDoc).toList());
  }

  /// One-time fetch
  Future<List<ApplicationModel>> fetchApplications(String uid) async {
    try {
      final snap = await _col
          .where('applicantId', isEqualTo: uid)
          .orderBy('appliedAt', descending: true)
          .get();
      return snap.docs.map(ApplicationModel.fromDoc).toList();
    } catch (e) {
      debugPrint('❌ AppliedJobsService.fetchApplications: $e');
      return [];
    }
  }

  /// Count applications by status for the overview card
  Future<Map<ApplicationStatus, int>> fetchStatusCounts(String uid) async {
    final apps = await fetchApplications(uid);
    final counts = <ApplicationStatus, int>{};
    for (final status in ApplicationStatus.values) {
      counts[status] = apps.where((a) => a.status == status).length;
    }
    return counts;
  }

  // ── Write ────────────────────────────────────────────────

  /// Submit a new application
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
      // Check if already applied
      final existing = await _col
          .where('applicantId', isEqualTo: uid)
          .where('offerId', isEqualTo: offerId)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        debugPrint('⚠️ Already applied to offer: $offerId');
        return null;
      }

      final ref = await _col.add({
        'applicantId':    uid,
        'offerId':        offerId,
        'offerTitle':     offerTitle,
        'company':        company,
        'companyInitial': companyInitial,
        'companyBgColor': companyBgColor,
        'companyColor':   companyColor,
        'location':       location,
        'jobType':        jobType,
        'salary':         salary,
        'appliedAt':      FieldValue.serverTimestamp(),
        'status':         'pending',
        'viewCount':      0,
      });

      // Update user stats
      await _db.collection('users').doc(uid).update({
        'stats.jobs.reviewing': FieldValue.increment(1),
      });

      return ref.id;
    } catch (e) {
      debugPrint('❌ AppliedJobsService.apply: $e');
      return null;
    }
  }

  /// Update status (by recruteur)
  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
    String? statusMessage,
  }) async {
    try {
      await _col.doc(applicationId).update({
        'status': ApplicationModel.statusToString(status),
        'statusMessage': ?statusMessage,
      });
    } catch (e) {
      debugPrint('❌ AppliedJobsService.updateStatus: $e');
    }
  }

  /// Increment view count
  Future<void> incrementView(String applicationId) async {
    await _col.doc(applicationId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Withdraw application
  Future<void> withdraw(String applicationId) async {
    try {
      await _col.doc(applicationId).delete();
    } catch (e) {
      debugPrint('❌ AppliedJobsService.withdraw: $e');
    }
  }
}
