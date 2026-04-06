import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';

class MediaService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// رفع صورة البروفايل + تحديث Firestore فوراً
  static Future<String?> uploadProfileImage(String uid, File file) async {
    final url = await CloudinaryService.upload(
      file: file,
      folder: 'users/$uid/profile',
    );

    if (url != null) {
      await _db.collection('users').doc(uid).update({'photoURL': url});
      return url;
    }
    return null;
  }
}