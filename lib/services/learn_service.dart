import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart'; // ✅ استيراد النموذج الموحد الوحيد

/// LearnService - يستخدم النموذج الموحد من ../models/course_model.dart
/// 
/// ملاحظة: هذا الملف يتعامل مع بيانات قد تحتوي على أسماء حقول قديمة في Firestore،
/// لذلك نستخدم دالة _docToCourseModel لتحويل الحقول القديمة إلى الجديدة.
///
/// الحقول القديمة → الجديدة:
/// - lessonsCount → totalLessons
/// - enrolledCount → enrolledStudents
/// - thumbnailUrl → imageUrl
/// - price → coursePrice
/// - instructor → instructorName

class LearnService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('courses');

  // ✅✅✅ دالة مساعدة خاصة: تحويل وثيقة Firestore إلى CourseModel موحد ✅✅✅
  // هذه الدالة تتعامل مع كل من الحقول القديمة والجديدة لضمان التوافق
  CourseModel _docToCourseModel(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    
    // التعامل مع createdAt (قد يكون Timestamp أو DateTime أو null)
    DateTime createdAt;
    final createdAtRaw = d['createdAt'];
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else {
      createdAt = DateTime.now();
    }

    // تحديد حالة النشر (يدعم isPublished القديمة و status الجديدة)
    final status = d['status'] ?? 
                   (d['isPublished'] == true ? 'approved' : 'pending');
    final isPublished = status == 'approved';

    return CourseModel(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      instructorId: d['instructorId'] ?? '',
      // دعم اسم المعلم القديم والجديد
      instructorName: d['instructorName'] ?? d['instructor'] ?? 'Enseignant',
      category: d['category'] ?? '',
      // دعم السعر القديم والجديد
      coursePrice: (d['coursePrice'] ?? d['price'] ?? 0).toDouble(),
      certificatePrice: (d['certificatePrice'] ?? 0).toDouble(),
      // دعم الصورة القديمة والجديدة
      imageUrl: d['imageUrl'] ?? d['thumbnailUrl'],
      unitsCount: d['unitsCount'] ?? 0,
      // دعم عدد الدروس القديم والجديد ← هذا يحل مشكلتك الرئيسية!
      totalLessons: d['totalLessons'] ?? d['lessonsCount'] ?? 0,
      // دعم عدد الطلاب القديم والجديد
      enrolledStudents: d['enrolledStudents'] ?? d['enrolledCount'] ?? 0,
      createdAt: createdAt,
      isPublished: isPublished,
      status: status,
      rating: (d['rating'] ?? 0).toDouble(),
    );
  }

  /// Stream of published courses with optional category filter (real-time)
  Stream<List<CourseModel>> streamCourses({String? category}) {
    Query<Map<String, dynamic>> q = _col
        .where('isPublished', isEqualTo: true)
        .orderBy('rating', descending: true);
    
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    
    // ✅ استخدام الدالة المساعدة بدلاً من fromDoc
    return q.snapshots().map((s) => s.docs.map(_docToCourseModel).toList());
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
      // ✅ استخدام الدالة المساعدة
      return snap.docs.map(_docToCourseModel).toList();
    } catch (e) {
      debugPrint('❌ LearnService.fetchCourses: $e');
      return [];
    }
  }

  /// Search courses by title (client-side filter after fetch)
  Future<List<CourseModel>> searchCourses(String query) async {
    try {
      final snap = await _col.where('isPublished', isEqualTo: true).get();
      // ✅ استخدام الدالة المساعدة
      final all = snap.docs.map(_docToCourseModel).toList();
      final q = query.toLowerCase();
      
      return all.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.instructorName.toLowerCase().contains(q) ||
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
      // ✅ استخدام الدالة المساعدة
      return doc.exists ? _docToCourseModel(doc) : null;
    } catch (e) {
      debugPrint('❌ LearnService.fetchCourse: $e');
      return null;
    }
  }

  /// Increment enrolledCount when a user enrolls
  /// ✅ هذه الدالة تحدّث الحقل القديم لضمان التوافق مع البيانات الحالية
  Future<void> incrementEnrolled(String courseId) async {
    try {
      // نحدّث كلا الحقلين لضمان التوافق مع الكود القديم والجديد
      await _col.doc(courseId).update({
        'enrolledCount': FieldValue.increment(1),
        'enrolledStudents': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('❌ LearnService.incrementEnrolled: $e');
    }
  }

  /// ✅ دالة جديدة: تحديث حالة الكورس (للدعم المستقبلي)
  Future<bool> updateCourseStatus(String courseId, String status) async {
    try {
      await _col.doc(courseId).update({
        'status': status,
        'isPublished': status == 'approved',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ LearnService.updateCourseStatus: $e');
      return false;
    }
  }
}