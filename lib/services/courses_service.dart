import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';

class CoursesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // مرجع لمجموعة الكورسات الرئيسية
  CollectionReference<Map<String, dynamic>> get _coursesRef => _db.collection('courses');

  /// ✅ إنشاء كورس جديد وحفظ بياناته الأساسية
  Future<String?> createCourse(CourseModel course) async {
    try {
      // نستخدم add() لتوليد ID تلقائي
      final docRef = await _coursesRef.add(course.toMap());
      debugPrint('✅ Course created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating course: $e');
      return null;
    }
  }

  /// ✅ جلب كورسات معلم معين (Stream لتحديث فوري)
  Stream<List<CourseModel>> getCoursesByInstructor(String instructorId) {
    return _coursesRef
        .where('instructorId', isEqualTo: instructorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }
  
  /// ✅ جلب كل الكورسات المنشورة (للطلاب)
  Stream<List<CourseModel>> getPublishedCourses({String? category}) {
    var query = _coursesRef.where('isPublished', isEqualTo: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.orderBy('createdAt', descending: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }


  /// ✅ جلب تفاصيل كورس واحد (بما في ذلك الدروس لاحقاً)
  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final doc = await _coursesRef.doc(courseId).get();
      if (doc.exists) {
        return CourseModel.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching course: $e');
      return null;
    }
  }
}