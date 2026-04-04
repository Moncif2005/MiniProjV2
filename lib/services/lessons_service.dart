import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /courses/{courseId}/lessons/{lessonId}
///   - title: String
///   - durationMinutes: int
///   - order: int          (1-based lesson index)
///   - videoUrl: String?
///   - description: String
///   - isFree: bool        (preview available without enrollment)
///   - createdAt: Timestamp
///
/// /users/{uid}/lessonProgress/{courseId}
///   - completedLessonIds: List<String>   (lessonId values)
///   - lastLessonId: String               (last lesson accessed)
///   - lastAccessedAt: Timestamp
///   - progressPercent: double            (0.0 – 1.0, computed)

class LessonModel {
  final String id;
  final String courseId;
  final String title;
  final int durationMinutes;
  final int order;
  final String? videoUrl;
  final String description;
  final bool isFree;
  final Timestamp createdAt;

  LessonModel({
    required this.id,
    required this.courseId,
    required this.title,
    required this.durationMinutes,
    required this.order,
    this.videoUrl,
    required this.description,
    required this.isFree,
    required this.createdAt,
  });

  factory LessonModel.fromDoc(DocumentSnapshot doc, String courseId) {
    final d = doc.data() as Map<String, dynamic>;
    return LessonModel(
      id:              doc.id,
      courseId:        courseId,
      title:           d['title']           ?? '',
      durationMinutes: d['durationMinutes'] ?? 0,
      order:           d['order']           ?? 0,
      videoUrl:        d['videoUrl'],
      description:     d['description']     ?? '',
      isFree:          d['isFree']          ?? false,
      createdAt:       d['createdAt']       ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':           title,
    'durationMinutes': durationMinutes,
    'order':           order,
    'videoUrl':        videoUrl,
    'description':     description,
    'isFree':          isFree,
    'createdAt':       createdAt,
  };

  String get durationFormatted {
    if (durationMinutes < 60) return '${durationMinutes} min';
    return '${durationMinutes ~/ 60}h ${durationMinutes % 60}min';
  }
}

class LessonProgress {
  final List<String> completedLessonIds;
  final String? lastLessonId;
  final Timestamp? lastAccessedAt;
  final double progressPercent;

  LessonProgress({
    required this.completedLessonIds,
    this.lastLessonId,
    this.lastAccessedAt,
    required this.progressPercent,
  });

  factory LessonProgress.fromMap(Map<String, dynamic> d) {
    return LessonProgress(
      completedLessonIds: List<String>.from(d['completedLessonIds'] ?? []),
      lastLessonId:       d['lastLessonId'],
      lastAccessedAt:     d['lastAccessedAt'],
      progressPercent:    (d['progressPercent'] ?? 0.0).toDouble(),
    );
  }

  factory LessonProgress.empty() => LessonProgress(
    completedLessonIds: [],
    progressPercent: 0.0,
  );
}

class LessonsService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _lessonsCol(String courseId) =>
      _db.collection('courses').doc(courseId).collection('lessons');

  CollectionReference<Map<String, dynamic>> _progressCol(String uid) =>
      _db.collection('users').doc(uid).collection('lessonProgress');

  // ── Lessons ──────────────────────────────────────────────

  /// Stream of lessons for a course, ordered by `order`
  Stream<List<LessonModel>> streamLessons(String courseId) {
    return _lessonsCol(courseId)
        .orderBy('order')
        .snapshots()
        .map((s) => s.docs.map((d) => LessonModel.fromDoc(d, courseId)).toList());
  }

  /// One-time fetch of lessons
  Future<List<LessonModel>> fetchLessons(String courseId) async {
    try {
      final snap = await _lessonsCol(courseId).orderBy('order').get();
      return snap.docs.map((d) => LessonModel.fromDoc(d, courseId)).toList();
    } catch (e) {
      debugPrint('❌ LessonsService.fetchLessons: $e');
      return [];
    }
  }

  /// Add a lesson to a course (enseignant)
  Future<String?> addLesson(String courseId, LessonModel lesson) async {
    try {
      final ref = await _lessonsCol(courseId).add(
        lesson.toMap()..['createdAt'] = FieldValue.serverTimestamp(),
      );
      // Update course lessonsCount
      await _db.collection('courses').doc(courseId).update({
        'lessonsCount': FieldValue.increment(1),
      });
      return ref.id;
    } catch (e) {
      debugPrint('❌ LessonsService.addLesson: $e');
      return null;
    }
  }

  // ── Progress ─────────────────────────────────────────────

  /// Stream of progress for a user on a specific course
  Stream<LessonProgress> streamProgress(String uid, String courseId) {
    return _progressCol(uid).doc(courseId).snapshots().map((doc) {
      if (!doc.exists) return LessonProgress.empty();
      return LessonProgress.fromMap(doc.data()!);
    });
  }

  /// Fetch progress once
  Future<LessonProgress> fetchProgress(String uid, String courseId) async {
    try {
      final doc = await _progressCol(uid).doc(courseId).get();
      if (!doc.exists) return LessonProgress.empty();
      return LessonProgress.fromMap(doc.data()!);
    } catch (e) {
      debugPrint('❌ LessonsService.fetchProgress: $e');
      return LessonProgress.empty();
    }
  }

  /// Mark a lesson as completed and update progress percentage
  Future<void> completeLesson({
    required String uid,
    required String courseId,
    required String lessonId,
    required int totalLessons,
  }) async {
    try {
      final ref = _progressCol(uid).doc(courseId);
      final doc = await ref.get();
      final List<String> completed = doc.exists
          ? List<String>.from(doc.data()!['completedLessonIds'] ?? [])
          : [];

      if (!completed.contains(lessonId)) {
        completed.add(lessonId);
      }

      final progress = totalLessons > 0 ? completed.length / totalLessons : 0.0;

      await ref.set({
        'completedLessonIds': completed,
        'lastLessonId':       lessonId,
        'lastAccessedAt':     FieldValue.serverTimestamp(),
        'progressPercent':    progress,
      }, SetOptions(merge: true));

      // Sync progress to user stats (enrolledCourses progress tracking)
      await _db.collection('users').doc(uid).update({
        'enrolledCoursesProgress.$courseId': progress,
      });
    } catch (e) {
      debugPrint('❌ LessonsService.completeLesson: $e');
    }
  }
}
