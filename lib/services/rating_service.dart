import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class RatingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // ✅ UID ديناميكي
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  /// ✅ إضافة أو تحديث تقييم مع تتبع كامل
  Future<void> rateCourse(String courseId, int rating) async {
    debugPrint('🔍 [RatingService] Starting rateCourse...');
    debugPrint('🔍 [RatingService] courseId: $courseId, rating: $rating');
    
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    debugPrint('🔍 [RatingService] currentUid from FirebaseAuth: $currentUid');
    
    if (currentUid == null) {
      debugPrint('❌ [RatingService] ERROR: User not authenticated!');
      return;
    }

    try {
      final courseRef = _db.collection('courses').doc(courseId);
      final ratingRef = courseRef.collection('ratings').doc(currentUid);
      
      debugPrint('🔍 [RatingService] Writing to: courses/$courseId/ratings/$currentUid');

      // 1️⃣ حفظ التقييم في المجموعة الفرعية
      await ratingRef.set({
        'userId': currentUid,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      debugPrint('✅ [RatingService] Rating saved to subcollection successfully');

      // 2️⃣ حساب المتوسط وتحديث الوثيقة الرئيسية
      debugPrint('🔍 [RatingService] Calculating new average...');
      final ratingsSnap = await courseRef.collection('ratings').get();
      
      if (ratingsSnap.docs.isNotEmpty) {
        double sum = 0;
        for (var doc in ratingsSnap.docs) {
          final r = doc['rating'];
          debugPrint('🔍 [RatingService] Found rating: $r');
          sum += (r as num).toDouble();
        }
        final avgRating = sum / ratingsSnap.docs.length;
        final totalCount = ratingsSnap.docs.length;
        
        debugPrint('🔍 [RatingService] New average: $avgRating, count: $totalCount');
        
        // تحديث الحقول في وثيقة الكورس الرئيسية
        await courseRef.update({
          'rating': avgRating,
          'ratingCount': totalCount,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        debugPrint('✅ [RatingService] Course document updated with new rating stats');
      } else {
        debugPrint('⚠️ [RatingService] No ratings found in subcollection (unexpected)');
      }

      debugPrint('🎉 [RatingService] rateCourse completed successfully!');
      
    } catch (e, stackTrace) {
      debugPrint('❌ [RatingService] FATAL ERROR: $e');
      debugPrint('❌ [RatingService] Stack trace: $stackTrace');
      rethrow; // لإعادة ظهور الخطأ في الـ UI
    }
  }

  /// ✅ جلب متوسط التقييم
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

  /// ✅ التحقق من تقييم المستخدم
  Stream<int?> getUserRatingStream(String courseId) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return Stream.value(null);

    return _db.collection('courses').doc(courseId).collection('ratings').doc(currentUid).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return snapshot['rating'] as int;
    });
  }
}