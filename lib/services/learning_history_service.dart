import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /users/{uid}/enrollments/{courseId}
///   - courseId: String
///   - courseTitle: String
///   - category: String
///   - enrolledAt: Timestamp
///   - lastAccessedAt: Timestamp
///   - progressPercent: double  (0.0 – 1.0)
///   - completedLessons: int
///   - totalLessons: int
///   - timeSpentMinutes: int
///   - isCompleted: bool
///   - completedAt: Timestamp?
///   - userRating: int?  (1-5, given after completion)
///
/// /users/{uid}  (top-level stats in user doc)
///   - stats.enrolledCourses: int
///   - stats.completedCourses: int
///   - stats.streakDays: int
///   - stats.totalLearningMinutes: int

class EnrollmentModel {
  final String courseId;
  final String courseTitle;
  final String category;
  final Timestamp enrolledAt;
  final Timestamp lastAccessedAt;
  final double progressPercent;
  final int completedLessons;
  final int totalLessons;
  final int timeSpentMinutes;
  final bool isCompleted;
  final Timestamp? completedAt;
  final int? userRating;

  EnrollmentModel({
    required this.courseId,
    required this.courseTitle,
    required this.category,
    required this.enrolledAt,
    required this.lastAccessedAt,
    required this.progressPercent,
    required this.completedLessons,
    required this.totalLessons,
    required this.timeSpentMinutes,
    required this.isCompleted,
    this.completedAt,
    this.userRating,
  });

  factory EnrollmentModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EnrollmentModel(
      courseId:          doc.id,
      courseTitle:       d['courseTitle']       ?? '',
      category:          d['category']          ?? '',
      enrolledAt:        d['enrolledAt']        ?? Timestamp.now(),
      lastAccessedAt:    d['lastAccessedAt']    ?? Timestamp.now(),
      progressPercent:   (d['progressPercent']  ?? 0.0).toDouble(),
      completedLessons:  d['completedLessons']  ?? 0,
      totalLessons:      d['totalLessons']      ?? 0,
      timeSpentMinutes:  d['timeSpentMinutes']  ?? 0,
      isCompleted:       d['isCompleted']       ?? false,
      completedAt:       d['completedAt'],
      userRating:        d['userRating'],
    );
  }

  Map<String, dynamic> toMap() => {
    'courseTitle':       courseTitle,
    'category':          category,
    'enrolledAt':        enrolledAt,
    'lastAccessedAt':    lastAccessedAt,
    'progressPercent':   progressPercent,
    'completedLessons':  completedLessons,
    'totalLessons':      totalLessons,
    'timeSpentMinutes':  timeSpentMinutes,
    'isCompleted':       isCompleted,
    if (completedAt != null) 'completedAt': completedAt,
    if (userRating  != null) 'userRating':  userRating,
  };

  String get lessonsLabel => '$completedLessons/$totalLessons leçons';

  String get timeSpentFormatted {
    final h = timeSpentMinutes ~/ 60;
    final m = timeSpentMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  String get lastAccessedLabel {
    final diff = DateTime.now().difference(lastAccessedAt.toDate());
    if (diff.inDays == 0)  return 'Today';
    if (diff.inDays == 1)  return 'Yesterday';
    if (diff.inDays < 7)   return '${diff.inDays} days ago';
    return '${(diff.inDays / 7).floor()} weeks ago';
  }

  String? get ratingEmoji {
    if (userRating == null) return null;
    return List.filled(userRating!, '⭐').join();
  }
}

class LearningHistoryService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _enrollCol(String uid) =>
      _db.collection('users').doc(uid).collection('enrollments');

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── Read ─────────────────────────────────────────────────

  /// Real-time stream of all enrollments
  Stream<List<EnrollmentModel>> streamEnrollments(String uid) {
    return _enrollCol(uid)
        .orderBy('lastAccessedAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(EnrollmentModel.fromDoc).toList());
  }

  /// One-time fetch
  Future<List<EnrollmentModel>> fetchEnrollments(String uid) async {
    try {
      final snap = await _enrollCol(uid)
          .orderBy('lastAccessedAt', descending: true)
          .get();
      return snap.docs.map(EnrollmentModel.fromDoc).toList();
    } catch (e) {
      debugPrint('❌ LearningHistoryService.fetchEnrollments: $e');
      return [];
    }
  }

  /// Fetch user-level learning stats from the user document
  Future<Map<String, dynamic>> fetchLearningStats(String uid) async {
    try {
      final doc = await _userDoc(uid).get();
      if (!doc.exists) return {};
      final stats = (doc.data()?['stats'] ?? {}) as Map<String, dynamic>;
      return {
        'enrolledCourses':       stats['enrolledCourses']       ?? 0,
        'completedCourses':      stats['completedCourses']      ?? 0,
        'streakDays':            stats['streakDays']            ?? 0,
        'totalLearningMinutes':  stats['totalLearningMinutes']  ?? 0,
      };
    } catch (e) {
      debugPrint('❌ LearningHistoryService.fetchLearningStats: $e');
      return {};
    }
  }

  // ── Write ────────────────────────────────────────────────

  /// Enroll a student in a course
  Future<bool> enroll({
    required String uid,
    required String courseId,
    required String courseTitle,
    required String category,
    required int totalLessons,
  }) async {
    try {
      await _enrollCol(uid).doc(courseId).set({
        'courseTitle':      courseTitle,
        'category':         category,
        'enrolledAt':       FieldValue.serverTimestamp(),
        'lastAccessedAt':   FieldValue.serverTimestamp(),
        'progressPercent':  0.0,
        'completedLessons': 0,
        'totalLessons':     totalLessons,
        'timeSpentMinutes': 0,
        'isCompleted':      false,
      }, SetOptions(merge: true));

      await _userDoc(uid).update({
        'stats.enrolledCourses': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      debugPrint('❌ LearningHistoryService.enroll: $e');
      return false;
    }
  }

  /// Update progress after completing a lesson
  Future<void> updateProgress({
    required String uid,
    required String courseId,
    required int completedLessons,
    required int totalLessons,
    required int addMinutes,
  }) async {
    try {
      final progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
      final isCompleted = progress >= 1.0;

      final updates = <String, dynamic>{
        'completedLessons':  completedLessons,
        'progressPercent':   progress,
        'timeSpentMinutes':  FieldValue.increment(addMinutes),
        'lastAccessedAt':    FieldValue.serverTimestamp(),
        'isCompleted':       isCompleted,
        if (isCompleted) 'completedAt': FieldValue.serverTimestamp(),
      };

      await _enrollCol(uid).doc(courseId).update(updates);

      await _userDoc(uid).update({
        'stats.totalLearningMinutes': FieldValue.increment(addMinutes),
        if (isCompleted) 'stats.completedCourses': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ LearningHistoryService.updateProgress: $e');
    }
  }

  /// Rate a completed course
  Future<void> rateCourse({
    required String uid,
    required String courseId,
    required int rating,
  }) async {
    try {
      await _enrollCol(uid).doc(courseId).update({'userRating': rating});
    } catch (e) {
      debugPrint('❌ LearningHistoryService.rateCourse: $e');
    }
  }
}
