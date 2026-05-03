import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructorId;
  final String instructorName;
  final String category;
  final double coursePrice;
  final double certificatePrice;
  final String? imageUrl;
  final int unitsCount;
  final int totalLessons;
  final int enrolledStudents;
  final DateTime createdAt;
  final bool isPublished;
  final String status; // ✅ الحقل الجديد: pending, approved, rejected
  final double rating;
    final int durationMinutes; // مدة الكورس بالدقائق


  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructorId,
    required this.instructorName,
    required this.category,
    this.coursePrice = 0.0,
    this.certificatePrice = 0.0,
    this.imageUrl,
    required this.unitsCount,
    required this.totalLessons,
    this.enrolledStudents = 0,
    required this.createdAt,
    this.isPublished = true,
    this.status = 'pending',
    this.rating = 0.0,
        this.durationMinutes = 0, // ✅ قيمة افتراضية

  });

  factory CourseModel.fromMap(String id, Map<String, dynamic> data) {
    return CourseModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructorId: data['instructorId'] ?? '',
      instructorName: data['instructorName'] ?? '',
      category: data['category'] ?? '',
      coursePrice: (data['coursePrice'] ?? 0).toDouble(),
      certificatePrice: (data['certificatePrice'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'],
      unitsCount: data['unitsCount'] ?? 0,
      totalLessons: data['totalLessons'] ?? 0,
      enrolledStudents: data['enrolledStudents'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPublished: data['isPublished'] ?? true,
      status: data['status'] ?? 'pending',
      rating: (data['rating'] ?? 0).toDouble(),
          durationMinutes: data['durationMinutes'] ?? data['duration_minutes'] ?? 0,

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'category': category,
      'coursePrice': coursePrice,
      'certificatePrice': certificatePrice,
      'imageUrl': imageUrl,
      'unitsCount': unitsCount,
      'totalLessons': totalLessons,
      'enrolledStudents': enrolledStudents,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPublished': isPublished,
      'status': status, // ✅ حفظ الحالة
          'durationMinutes': durationMinutes,

    };
  }
    String get durationFormatted {
    if (durationMinutes <= 0) return '—';
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '$m min';
    if (m == 0) return '${h}h';
    return '${h}h ${m}min';
  }

}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class CourseModel {
//   final String id;
//   final String title;
//   final String description;
//   final String instructorId;
//   final String instructorName;
//   final String category;
//   final double coursePrice;
//   final double certificatePrice;
//   final String? imageUrl;
//   final int unitsCount;
//   final int totalLessons;
//   final int enrolledStudents;
//   final DateTime createdAt;
//   final bool isPublished;

//   CourseModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.instructorId,
//     required this.instructorName,
//     required this.category,
//     this.coursePrice = 0.0,
//     this.certificatePrice = 0.0,
//     this.imageUrl,
//     required this.unitsCount,
//     required this.totalLessons,
//     this.enrolledStudents = 0,
//     required this.createdAt,
//     this.isPublished = true,
//   });

//   // تحويل من Map (Firestore) إلى Object
//   factory CourseModel.fromMap(String id, Map<String, dynamic> data) {
//     return CourseModel(
//       id: id,
//       title: data['title'] ?? '',
//       description: data['description'] ?? '',
//       instructorId: data['instructorId'] ?? '',
//       instructorName: data['instructorName'] ?? '',
//       category: data['category'] ?? '',
//       coursePrice: (data['coursePrice'] ?? 0).toDouble(),
//       certificatePrice: (data['certificatePrice'] ?? 0).toDouble(),
//       imageUrl: data['imageUrl'],
//       unitsCount: data['unitsCount'] ?? 0,
//       totalLessons: data['totalLessons'] ?? 0,
//       enrolledStudents: data['enrolledStudents'] ?? 0,
//       createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       isPublished: data['isPublished'] ?? true,
//     );
//   }

//   // تحويل من Object إلى Map (للحفظ في Firestore)
//   Map<String, dynamic> toMap() {
//     return {
//       'title': title,
//       'description': description,
//       'instructorId': instructorId,
//       'instructorName': instructorName,
//       'category': category,
//       'coursePrice': coursePrice,
//       'certificatePrice': certificatePrice,
//       'imageUrl': imageUrl,
//       'unitsCount': unitsCount,
//       'totalLessons': totalLessons,
//       'enrolledStudents': enrolledStudents,
//       'createdAt': Timestamp.fromDate(createdAt),
//       'isPublished': isPublished,
//     };
//   }
// }
