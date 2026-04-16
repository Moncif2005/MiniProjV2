import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  // ⚠️ استبدل هذه القيم ببياناتك الحقيقية
  static const String cloudName = 'dtewlhqst';
  static const String uploadPreset = 'formanova_uploads';

  static Future<String?> upload({
    required File file,
    required String folder,
    String? resourceType, // ✅ جديد: 'image' (افتراضي) أو 'raw' للـ PDF
  }) async {
    try {
      // ✅ 1. تحديد نوع المورد ورابط الـ API المناسب
      final type = resourceType ?? 'image';
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/$type/upload', // ✅ ديناميكي: image/upload أو raw/upload
      );

      final request = http.MultipartRequest('POST', url);
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;

      // ✅ 2. إعداد الملف للإرسال
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final fileName = file.path.split('/').last;

      final multipartFile = http.MultipartFile(
        'file',
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // ✅ 3. الإرسال والمعالجة
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['secure_url']; // ✅ رابط آمن يعمل للجميع
      } else {
        debugPrint('❌ Upload Failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Cloudinary Exception: $e');
      debugPrint('📚 Stack: $stackTrace');
      return null;
    }
  }
}
