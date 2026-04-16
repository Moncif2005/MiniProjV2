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

  // /// رفع السيرة الذاتية (CV)
  
  // static Future<String?> uploadCV(String uid, File file) async {
  //   return await CloudinaryService.upload(
  //     file: file, 
  //     folder: 'users/$uid/cv'
  //   );
  // }

    // ── دوال جديدة للبورتفوليو والشهادات ──

  /// ✅ رفع ملف البورتفوليو (صورة مشروع أو شهادة خارجية)
  static Future<String?> uploadPortfolioItem(String itemId, File file) async {
    // نستخدم 'image' للمشاريع والشهادات المصورة
    return await CloudinaryService.upload(
      file: file, 
      folder: 'minipr/portfolio', 
      resourceType: 'image', 
    );
  }

  /// رفع السيرة الذاتية (CV) بذكاء
  static Future<String?> uploadCV(String uid, File file) async {
    // ✅ التحقق: هل هو PDF أم صورة؟
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    
    // ✅ إذا كان صورة، نرفعه كصورة (ليظهر مباشرة)
    // ✅ إذا كان PDF، نرفعه كملف Raw (لأنه المستند الصحيح)
    final type = isPdf ? 'raw' : 'image';
    
    return await CloudinaryService.upload(
      file: file, 
      folder: 'minipr/cv_pdfs', 
      resourceType: type, // ✅ هنا السر!
    );
  }
  /// ✅ رفع شهادة داخلية (صورة الشهادة المولدة)
  static Future<String?> uploadInternalCertificate(String certId, File file) async {
    return await CloudinaryService.upload(
      file: file, 
      folder: 'minipr/certificates', 
      resourceType: 'image',
    );
  }
}