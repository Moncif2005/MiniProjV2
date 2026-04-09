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
  }) async {
    try {
      // ✅ تحقق من البيانات
      if (cloudName == 'YOUR_CLOUD_NAME' ||
          uploadPreset == 'YOUR_UNSIGNED_PRESET') {
        debugPrint('❌ ERROR: Cloudinary credentials not set!');
        debugPrint(
          '📝 Please update cloudName and uploadPreset in cloudinary_service.dart',
        );
        return null;
      }

      debugPrint('☁️ Cloudinary Upload Started');
      debugPrint('📁 File: ${file.path}');
      debugPrint('📂 Folder: $folder');
      debugPrint('🔑 Cloud Name: $cloudName');
      debugPrint('⚙️ Preset: $uploadPreset');

      // ✅ استخدم endpoint خاص بالصور (أكثر موثوقية)
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url);

      // ✅ أضف الحقول المطلوبة
      request.fields['upload_preset'] = uploadPreset;
      request.fields['folder'] = folder;
      // request.fields['use_filename'] = 'true';
      // request.fields['unique_filename'] = 'false'; // ✅ لتجنب الأسماء العشوائية

      // ✅ أضف الملف
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

      debugPrint('📤 Sending request to Cloudinary...');

      // ✅ أرسل الطلب
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('📥 Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final secureUrl = jsonData['secure_url'];
        debugPrint('✅ Upload Success! URL: $secureUrl');
        return secureUrl;
      } else {
        debugPrint('❌ Upload Failed with status: ${response.statusCode}');
        debugPrint('❌ Erro°r: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Exception during upload: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      return null;
    }
  }
}
