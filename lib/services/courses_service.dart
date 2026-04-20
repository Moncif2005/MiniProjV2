import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/course_model.dart';

class CoursesService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ✅ المرجع الأساسي للكورسات
  CollectionReference<Map<String, dynamic>> get _coursesRef => _db.collection('courses');

  /// ✅ إنشاء كورس جديد
  Future<String?> createCourse(CourseModel course) async {
    try {
      final docRef = await _coursesRef.add(course.toMap());
      debugPrint('✅ Course created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating course: $e');
      return null;
    }
  }

  /// ✅ جلب كورسات معلم معين
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

  /// ✅ جلب الكورسات قيد المراجعة
  Stream<List<CourseModel>> getPendingCourses() {
    return _coursesRef
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// ✅ الموافقة على كورس
  Future<bool> approveCourse(String courseId) async {
    try {
      await _coursesRef.doc(courseId).update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error approving course: $e');
      return false;
    }
  }

  /// ✅ رفض كورس
  Future<bool> rejectCourse(String courseId) async {
    try {
      await _coursesRef.doc(courseId).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error rejecting course: $e');
      return false;
    }
  }

  /// ✅ جلب الكورسات المنشورة (للطلاب) - يعتمد على status فقط
  Stream<List<CourseModel>> getPublishedCourses({String? category}) {
    var query = _coursesRef
        .where('status', isEqualTo: 'approved') 
        .orderBy('createdAt', descending: true);
    
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return CourseModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// ✅ جلب تفاصيل كورس واحد
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

  // ✅✅✅ دالة الحذف (مضافة بشكل صحيح داخل الكلاس) ✅✅✅
  Future<bool> deleteCourse(String courseId) async {
    try {
      // 1. حذف الدروس المرتبطة أولاً
      final lessonsSnapshot = await _db.collection('courses').doc(courseId).collection('lessons').get();
      for (var doc in lessonsSnapshot.docs) {
        await doc.reference.delete();
      }

      // 2. حذف وثيقة الكورس الرئيسية
      await _coursesRef.doc(courseId).delete();
      
      debugPrint('✅ Course deleted: $courseId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting course: $e');
      return false;
    }
  }
}