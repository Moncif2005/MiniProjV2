import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';
import 'package:flutter/foundation.dart';

class MediaService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// رفع صورة البروفايل + تحديث/إنشاء وثيقة المستخدم في Firestore
  static Future<String?> uploadProfileImage(String uid, File file) async {
    debugPrint('📤 MediaService: Uploading profile image for $uid');
    
    // 1. الرفع لـ Cloudinary
    final url = await CloudinaryService.upload(
      file: file,
      folder: 'users/$uid/profile',
    );

    if (url != null) {
      debugPrint('✅ Cloudinary returned URL: $url');
      
      // 2. تحديث أو إنشاء الوثيقة في Firestore
      try {
        await _db.collection('users').doc(uid).set({
          'photoURL': url,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // ✅ هذا هو السطر السحري!
        
        debugPrint('✅ Firestore updated/created with photoURL');
        return url;
      } catch (e) {
        debugPrint('❌ Failed to update Firestore: $e');
        rethrow;
      }
    } else {
      debugPrint('❌ Cloudinary upload failed');
      return null;
    }
  }

  /// رفع السيرة الذاتية (CV)
  static Future<String?> uploadCV(String uid, File file) async {
    return await CloudinaryService.upload(
      file: file, 
      folder: 'users/$uid/cv'
    );
  }
}