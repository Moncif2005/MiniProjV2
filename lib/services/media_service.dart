import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';
import 'package:flutter/foundation.dart';

class MediaService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// رفع صورة البروفايل + تحديث Firestore فوراً
  static Future<String?> uploadProfileImage(String uid, File file) async {
    debugPrint('📤 MediaService: Uploading profile image for $uid');
    
    // 1. الرفع لـ Cloudinary
    final url = await CloudinaryService.upload(
      file: file,
      folder: 'users/$uid/profile',
    );

    if (url != null) {
      debugPrint('✅ Cloudinary returned URL: $url');
      
      // 2. تحديث Firestore
      try {
        await _db.collection('users').doc(uid).update({
          'photoURL': url,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('✅ Firestore updated with photoURL');
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
}