import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? _uid = FirebaseAuth.instance.currentUser?.uid;

  /// ✅ إضافة أو تحديث تقييم لكورس معين
  Future<void> rateCourse(String courseId, int rating) async {
    if (_uid == null) return;

    final docRef = _db.collection('courses').doc(courseId).collection('ratings').doc(_uid);

    await docRef.set({
      'userId': _uid,
      'rating': rating,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    debugPrint('✅ Rated course $courseId with $rating stars');
  }

  /// ✅ جلب متوسط التقييم وعدد المقيّمين (Stream لتحديث فوري)
  Stream<Map<String, dynamic>> getCourseRatingStats(String courseId) {
    return _db.collection('courses').doc(courseId).collection('ratings').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return {'average': 0.0, 'count': 0};
      }

      double sum = 0;
      for (var doc in snapshot.docs) {
        sum += (doc['rating'] as num).toDouble();
      }

      return {
        'average': sum / snapshot.docs.length,
        'count': snapshot.docs.length,
      };
    });
  }

  /// ✅ التحقق مما إذا كان المستخدم قد قيم الكورس مسبقاً وجلب تقييمه
  Stream<int?> getUserRatingStream(String courseId) {
    if (_uid == null) return Stream.value(null);

    return _db.collection('courses').doc(courseId).collection('ratings').doc(_uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot['rating'] as int;
    });
  }
}