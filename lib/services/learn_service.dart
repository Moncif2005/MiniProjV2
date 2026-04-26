import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /courses/{courseId}
///   - title: String
///   - instructor: String
///   - instructorId: String (uid of enseignant)
///   - rating: double
///   - ratingCount: int
///   - category: String  ('Languages' | 'Design' | 'Coding' | 'Business' | ...)
///   - durationMinutes: int
///   - lessonsCount: int
///   - price: double  (0 = free)
///   - thumbnailUrl: String?
///   - description: String
///   - isPublished: bool
///   - createdAt: Timestamp
///   - enrolledCount: int

class CourseModel {
  final String id;
  final String title;
  final String instructor;
  final String instructorId;
  final double rating;
  final int ratingCount;
  final String category;
  final int durationMinutes;
  final int lessonsCount;
  final double price;
  final String? thumbnailUrl;
  final String description;
  final bool isPublished;
  final Timestamp createdAt;
  final int enrolledCount;

  CourseModel({
    required this.id,
    required this.title,
    required this.instructor,
    required this.instructorId,
    required this.rating,
    required this.ratingCount,
    required this.category,
    required this.durationMinutes,
    required this.lessonsCount,
    required this.price,
    this.thumbnailUrl,
    required this.description,
    required this.isPublished,
    required this.createdAt,
    required this.enrolledCount,
  });

  factory CourseModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id:              doc.id,
      title:           d['title']           ?? '',
      instructor:      d['instructor']      ?? '',
      instructorId:    d['instructorId']    ?? '',
      rating:          (d['rating']         ?? 0.0).toDouble(),
      ratingCount:     d['ratingCount']     ?? 0,
      category:        d['category']        ?? '',
      durationMinutes: d['durationMinutes'] ?? 0,
      lessonsCount:    d['lessonsCount']    ?? 0,
      price:           (d['price']          ?? 0.0).toDouble(),
      thumbnailUrl:    d['thumbnailUrl'],
      description:     d['description']     ?? '',
      isPublished:     d['isPublished']     ?? false,
      createdAt:       d['createdAt']       ?? Timestamp.now(),
      enrolledCount:   d['enrolledCount']   ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'title':           title,
    'instructor':      instructor,
    'instructorId':    instructorId,
    'rating':          rating,
    'ratingCount':     ratingCount,
    'category':        category,
    'durationMinutes': durationMinutes,
    'lessonsCount':    lessonsCount,
    'price':           price,
    'thumbnailUrl':    thumbnailUrl,
    'description':     description,
    'isPublished':     isPublished,
    'createdAt':       createdAt,
    'enrolledCount':   enrolledCount,
  };

  /// e.g. "12h 30min"
  String get durationFormatted {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

  String get ratingFormatted => rating.toStringAsFixed(1);
}

class LearnService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('courses');

  /// Stream of published courses with optional category filter (real-time)
  Stream<List<CourseModel>> streamCourses({String? category}) {
    Query<Map<String, dynamic>> q = _col
        .where('isPublished', isEqualTo: true)
        .orderBy('rating', descending: true);
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map((s) => s.docs.map(CourseModel.fromDoc).toList());
  }

  /// One-time fetch
  Future<List<CourseModel>> fetchCourses({String? category}) async {
    try {
      Query<Map<String, dynamic>> q = _col
          .where('isPublished', isEqualTo: true)
          .orderBy('rating', descending: true);
      if (category != null && category != 'All') {
        q = q.where('category', isEqualTo: category);
      }
      final snap = await q.get();
      return snap.docs.map(CourseModel.fromDoc).toList();
    } catch (e) {
      debugPrint('❌ LearnService.fetchCourses: $e');
      return [];
    }
  }

  /// Search courses by title (client-side filter after fetch)
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snap = await _col.where('isPublished', isEqualTo: true).get();
      final all = snap.docs.map(CourseModel.fromDoc).toList();
      final q = query.toLowerCase();
      return all.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.instructor.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q)).toList();
    } catch (e) {
      debugPrint('❌ LearnService.searchCourses: $e');
      return [];
    }
  }

  /// Fetch a single course by ID
  Future<CourseModel?> fetchCourse(String courseId) async {
    try {
      final doc = await _col.doc(courseId).get();
      return doc.exists ? CourseModel.fromDoc(doc) : null;
    } catch (e) {
      debugPrint('❌ LearnService.fetchCourse: $e');
      return null;
    }
  }

  /// Increment enrolledCount when a user enrolls
  Future<void> incrementEnrolled(String courseId) async {
    await _col.doc(courseId).update({'enrolledCount': FieldValue.increment(1)});
  }
}
