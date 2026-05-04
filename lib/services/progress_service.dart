import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProgressService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ✅ تحسين: جلب الـ UID ديناميكياً في كل مرة لضمان الدقة
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // مرجع لمجموعة التقدم الخاصة بالمستخدم الحالي
  CollectionReference<Map<String, dynamic>>? get _progressRef {
    if (_uid == null) return null;
    return _db.collection('users').doc(_uid).collection('lessonProgress');
  }

  /// ✅ إضافة درس إلى قائمة المكتملات
  Future<void> markLessonAsComplete(String courseId, String lessonId) async {
    if (_uid == null || _progressRef == null) {
      debugPrint('❌ User not logged in');
      return;
    }

    final docRef = _progressRef!.doc(courseId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      
      List<String> completedLessons = [];
      int totalLessons = 0;

      if (snapshot.exists) {
        final data = snapshot.data()!;
        completedLessons = List<String>.from(data['completedLessons'] ?? []);
        totalLessons = data['totalLessons'] ?? 0;
      }

      // إضافة الدرس إذا لم يكن موجوداً بالفعل
      if (!completedLessons.contains(lessonId)) {
        completedLessons.add(lessonId);
        
        transaction.set(docRef, {
          'completedLessons': completedLessons,
          'totalLessons': totalLessons,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
    
    debugPrint('✅ Lesson $lessonId marked as complete in course $courseId');
  }

  /// ✅ تحديث العدد الكلي للدروس
  Future<void> updateTotalLessons(String courseId, int count) async {
    if (_uid == null || _progressRef == null) return;
    
    await _progressRef!.doc(courseId).set({
      'totalLessons': count,
    }, SetOptions(merge: true));
  }
  /// ✅✅✅ دالة تسجيل طالب في كورس (مصححة)
Future<void> enrollStudentInCourse({required String courseId, required String studentId}) async {
  try {
    final courseRef = _db.collection('courses').doc(courseId);
    final enrollmentRef = courseRef.collection('enrollments').doc(studentId);
    
    // ✅ أولاً: تحقق إذا كان الطالب مسجلاً مسبقاً
    final enrollmentDoc = await enrollmentRef.get();
    
    if (!enrollmentDoc.exists) {
      // ✅ تسجيل جديد: أنشئ الوثيقة وزد العداد
      await enrollmentRef.set({
        'enrolledAt': FieldValue.serverTimestamp(),
        'studentId': studentId,
      });
      
      // ✅ زد العداد مرة واحدة فقط
      await courseRef.update({
        'enrolledStudents': FieldValue.increment(1),
      });
      
      debugPrint('✅ New enrollment: $studentId in $courseId');
    } else {
      debugPrint('ℹ️ Student already enrolled: $studentId in $courseId');
    }
  } catch (e) {
    debugPrint('❌ Error enrolling student: $e');
  }
}
  /// ✅ جلب نسبة الإنجاز لكورس معين (Stream)
  Stream<double> getCourseProgressStream(String courseId) {
    if (_uid == null || _progressRef == null) return Stream.value(0.0);

    return _progressRef!.doc(courseId).snapshots().map((snapshot) {
      if (!snapshot.exists) return 0.0;
      
      final data = snapshot.data()!;
      final completed = (data['completedLessons'] as List?)?.length ?? 0;
      final total = data['totalLessons'] ?? 0;

      if (total == 0) return 0.0;
      return completed / total;
    });
  }
  
  /// ✅ التحقق مما إذا كان درس معين مكتملاً
  Stream<bool> isLessonCompletedStream(String courseId, String lessonId) {
     if (_uid == null || _progressRef == null) return Stream.value(false);

    return _progressRef!.doc(courseId).snapshots().map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data()!;
      final completedLessons = List<String>.from(data['completedLessons'] ?? []);
      return completedLessons.contains(lessonId);
    });
  }

  /// ✅ جلب معرفات الدروس المكتملة فقط (نسخة آمنة ومقاومة للأخطاء)
  Stream<Set<String>> getCompletedLessonsStream(String courseId) {
    // إذا لم يكن هناك مستخدم، نعيد مجموعة فارغة فوراً دون محاولة الاتصال
    if (_uid == null || _progressRef == null) return Stream.value({});

    return _progressRef!.doc(courseId).snapshots().map((snapshot) {
      try {
        if (!snapshot.exists) return <String>{};
        
        final data = snapshot.data();
        if (data == null || !data.containsKey('completedLessons')) {
          return <String>{};
        }

        // محاولة آمنة لتحويل القائمة
        final rawList = data['completedLessons'];
        if (rawList is List) {
          return rawList.whereType<String>().toSet();
        }
        return <String>{};
      } catch (e) {
        debugPrint('❌ Error in getCompletedLessonsStream: $e');
        return <String>{}; // في حال حدوث خطأ، نعيد مجموعة فارغة ولا نسقط التطبيق
      }
    }).handleError((error) {
      debugPrint('❌ Stream Error: $error');
      return <String>{};
    });
  }
  }
  