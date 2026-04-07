import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class OffersService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _offersRef => _db.collection('offers');
  CollectionReference<Map<String, dynamic>> get _applicationsRef => _db.collection('applications');

  // ─────────────────────────────────────────────────────────────
  // ✅ CREATE: نشر عرض وظيفة جديد
  // ─────────────────────────────────────────────────────────────
  Future<String?> createOffer({
    required String recruiterId,
    required String recruiterName,
    required String title,
    required String company,
    required String location,
    required String salary,
    required String jobType, // Full-time, Freelance, etc.
    required String description,
    String? companyLogo, // URL optional
  }) async {
    try {
      final docRef = await _offersRef.add({
        'title': title,
        'company': company,
        'recruiterId': recruiterId,
        'recruiterName': recruiterName,
        'location': location,
        'salary': salary,
        'jobType': jobType,
        'description': description,
        'companyLogo': companyLogo,
        // UI Helpers (للألوان والرموز)
        'companyInitial': company.isNotEmpty ? company[0].toUpperCase() : 'C',
        'companyBgColor': 4293848063, // أزرق افتراضي (يمكن تعديله)
        'companyColor': 4283322870,
        // Metadata
        'isActive': true,
        'postedAt': FieldValue.serverTimestamp(),
        'applicationsCount': 0,
      });
      debugPrint('✅ Offer created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating offer: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ READ: جلب العروض النشطة (للصفحة الرئيسية/الطلاب)
  // ─────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getActiveOffers({String? jobType, String? searchQuery}) {
    var query = _offersRef.where('isActive', isEqualTo: true);

    if (jobType != null && jobType.isNotEmpty) {
      query = query.where('jobType', isEqualTo: jobType);
    }

    // ملاحظة: البحث النصي يتطلب إعدادات خاصة في Firestore، هنا نفلتر محلياً للسهولة
    return query.orderBy('postedAt', descending: true).snapshots().map((snapshot) {
      var offers = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      // فلترة البحث محلياً (لأن Firestore لا يدعم search كامل بدون إضافات)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        offers = offers.where((offer) => 
          offer['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          offer['company'].toString().toLowerCase().contains(searchQuery.toLowerCase())
        ).toList();
      }
      return offers;
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ READ: جلب وظائف مسؤول توظيف معين
  // ─────────────────────────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> getOffersByRecruiter(String recruiterId) {
    return _offersRef
        .where('recruiterId', isEqualTo: recruiterId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return data;
            }).toList());
  }

// ─────────────────────────────────────────────────────────────
// ✅ UPDATE: تعديل عرض وظيفة موجود
// ─────────────────────────────────────────────────────────────
Future<bool> updateOffer({
  required String offerId,
  required String title,
  required String location,
  required String salary,
  required String jobType,
  required String description,
  String? company, // اختياري
}) async {
  try {
    await _offersRef.doc(offerId).update({
      'title': title,
      'location': location,
      'salary': salary,
      'jobType': jobType,
      'description': description,
      if (company != null) 'company': company,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Offer updated: $offerId');
    return true;
  } catch (e) {
    debugPrint('❌ Error updating offer: $e');
    return false;
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ READ: جلب طلبات التقديم لوظيفة معينة
// ─────────────────────────────────────────────────────────────
Stream<List<Map<String, dynamic>>> getApplicationsForOffer(String offerId) {
  return _applicationsRef
      .where('offerId', isEqualTo: offerId)
      .orderBy('appliedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList());
}

// ─────────────────────────────────────────────────────────────
// ✅ UPDATE: تحديث حالة طلب التقديم
// ─────────────────────────────────────────────────────────────
Future<bool> updateApplicationStatus({
  required String applicationId,
  required String status, // reviewing, interview, accepted, rejected
  String? message,
}) async {
  try {
    await _applicationsRef.doc(applicationId).update({
      'status': status,
      'statusMessage': message,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    debugPrint('✅ Application status updated: $applicationId → $status');
    return true;
  } catch (e) {
    debugPrint('❌ Error updating application: $e');
    return false;
  }
}

  // ─────────────────────────────────────────────────────────────
  // ✅ DELETE: إلغاء عرض (Soft Delete)
  // ─────────────────────────────────────────────────────────────
  Future<bool> deactivateOffer(String offerId) async {
    try {
      await _offersRef.doc(offerId).update({
        'isActive': false,
        'deactivatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error deactivating offer: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✅ APPLY: تقديم طالب على وظيفة (ينشئ وثيقة في /applications)
  // ─────────────────────────────────────────────────────────────
  Future<bool> applyToJob({
    required String applicantId,
    required String applicantName,
    required String offerId,
    required String offerTitle,
    required String company,
    required String location,
    required String jobType,
    required String salary,
  }) async {
    try {
      // 1. إنشاء طلب التقديم
      await _applicationsRef.add({
        'applicantId': applicantId,
        'applicantName': applicantName,
        'offerId': offerId,
        'offerTitle': offerTitle,
        'company': company,
        'location': location,
        'jobType': jobType,
        'salary': salary,
        'appliedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // pending, reviewing, interview, accepted, rejected
        'statusMessage': null,
        'viewCount': 0,
      });

      // 2. زيادة عداد التقديمات في العرض الأصلي (اختياري لكن مفيد)
      await _offersRef.doc(offerId).update({
        'applicationsCount': FieldValue.increment(1),
      });

      debugPrint('✅ Application submitted successfully');
      return true;
    } catch (e) {
      debugPrint('❌ Error applying to job: $e');
      return false;
    }
  }

// ─────────────────────────────────────────────────────────────
// ✅ STATS: جلب إحصائيات مسؤول التوظيف
// ─────────────────────────────────────────────────────────────
Future<Map<String, dynamic>> getRecruiterStats(String recruiterId) async {
  try {
    // 1. عدد الوظائف النشطة
    final jobsSnapshot = await _offersRef
        .where('recruiterId', isEqualTo: recruiterId)
        .where('isActive', isEqualTo: true)
        .count()
        .get();
    
    // 2. إجمالي المتقدمين لكل الوظائف
    final appsSnapshot = await _applicationsRef
        .where('offerId', whereIn: await _offersRef
            .where('recruiterId', isEqualTo: recruiterId)
            .get()
            .then((s) => s.docs.map((d) => d.id).toList()))
        .count()
        .get();
    
    // 3. عدد المقبولين (hired)
    final hiredSnapshot = await _applicationsRef
        .where('offerId', whereIn: await _offersRef
            .where('recruiterId', isEqualTo: recruiterId)
            .get()
            .then((s) => s.docs.map((d) => d.id).toList()))
        .where('status', isEqualTo: 'accepted')
        .count()
        .get();

    return {
      'jobsPosted': jobsSnapshot.count ?? 0,
      'totalApplicants': appsSnapshot.count ?? 0,
      'hiredCount': hiredSnapshot.count ?? 0,
    };
  } catch (e) {
    debugPrint('❌ Error fetching recruiter stats: $e');
    return {'jobsPosted': 0, 'totalApplicants': 0, 'hiredCount': 0};
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ READ: جلب جميع المتقدمين لوظائف مسؤول معين
// ─────────────────────────────────────────────────────────────
Stream<List<Map<String, dynamic>>> getAllApplicantsForRecruiter(String recruiterId) {
  // نحتاج أولاً لجلب معرفات وظائف هذا المسؤول
  return _offersRef
      .where('recruiterId', isEqualTo: recruiterId)
      .snapshots()
      .asyncMap((offersSnapshot) async {
        final offerIds = offersSnapshot.docs.map((d) => d.id).toList();
        if (offerIds.isEmpty) return <Map<String, dynamic>>[];
        
        final appsSnapshot = await _applicationsRef
            .where('offerId', whereIn: offerIds)
            .orderBy('appliedAt', descending: true)
            .get();
        
        return appsSnapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
}

  // ─────────────────────────────────────────────────────────────
// ✅ CHECK: هل قدم هذا المستخدم على هذه الوظيفة من قبل؟
// ─────────────────────────────────────────────────────────────
Future<bool> hasUserAppliedToJob({
  required String applicantId,
  required String offerId,
}) async {
  try {
    final snapshot = await _applicationsRef
        .where('applicantId', isEqualTo: applicantId)
        .where('offerId', isEqualTo: offerId)
        .limit(1)
        .get();
    
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    debugPrint('❌ Error checking application: $e');
    return false;
  }
}

// ─────────────────────────────────────────────────────────────
// ✅ WITHDRAW: سحب طلب التقديم (للطالب)
// ─────────────────────────────────────────────────────────────
Future<bool> withdrawApplication({
  required String applicantId,
  required String offerId,
}) async {
  try {
    // 1. ابحث عن وثيقة التقديم
    final snapshot = await _applicationsRef
        .where('applicantId', isEqualTo: applicantId)
        .where('offerId', isEqualTo: offerId)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) return false;
    
    final appId = snapshot.docs.first.id;
    
    // 2. احذف وثيقة التقديم
    await _applicationsRef.doc(appId).delete();
    
    // 3. ناقص عداد التقديمات في العرض الأصلي
    await _offersRef.doc(offerId).update({
      'applicationsCount': FieldValue.increment(-1),
    });
    
    debugPrint('✅ Application withdrawn successfully');
    return true;
  } catch (e) {
    debugPrint('❌ Error withdrawing application: $e');
    return false;
  }
}

}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';

// /// Firestore structure:
// /// /offers/{offerId}
// ///   - title: String
// ///   - company: String
// ///   - companyInitial: String
// ///   - companyBgColor: int (Color.value)
// ///   - companyColor: int (Color.value)
// ///   - location: String
// ///   - postedAt: Timestamp
// ///   - salary: String
// ///   - jobType: String  ('Full-time' | 'Freelance' | 'Contract' | 'Remote')
// ///   - isActive: bool
// ///   - description: String
// ///   - recruiterId: String (uid of the recruteur who posted it)

// class OfferModel {
//   final String id;
//   final String title;
//   final String company;
//   final String companyInitial;
//   final int companyBgColor;
//   final int companyColor;
//   final String location;
//   final Timestamp postedAt;
//   final String salary;
//   final String jobType;
//   final bool isActive;
//   final String description;
//   final String recruiterId;

//   OfferModel({
//     required this.id,
//     required this.title,
//     required this.company,
//     required this.companyInitial,
//     required this.companyBgColor,
//     required this.companyColor,
//     required this.location,
//     required this.postedAt,
//     required this.salary,
//     required this.jobType,
//     required this.isActive,
//     required this.description,
//     required this.recruiterId,
//   });

//   factory OfferModel.fromDoc(DocumentSnapshot doc) {
//     final d = doc.data() as Map<String, dynamic>;
//     return OfferModel(
//       id:              doc.id,
//       title:           d['title']          ?? '',
//       company:         d['company']        ?? '',
//       companyInitial:  d['companyInitial'] ?? '',
//       companyBgColor:  d['companyBgColor'] ?? 0xFFE0E7FF,
//       companyColor:    d['companyColor']   ?? 0xFF4F39F6,
//       location:        d['location']       ?? '',
//       postedAt:        d['postedAt']       ?? Timestamp.now(),
//       salary:          d['salary']         ?? '',
//       jobType:         d['jobType']        ?? 'Full-time',
//       isActive:        d['isActive']       ?? true,
//       description:     d['description']   ?? '',
//       recruiterId:     d['recruiterId']    ?? '',
//     );
//   }

//   Map<String, dynamic> toMap() => {
//     'title':          title,
//     'company':        company,
//     'companyInitial': companyInitial,
//     'companyBgColor': companyBgColor,
//     'companyColor':   companyColor,
//     'location':       location,
//     'postedAt':       postedAt,
//     'salary':         salary,
//     'jobType':        jobType,
//     'isActive':       isActive,
//     'description':    description,
//     'recruiterId':    recruiterId,
//   };

//   /// How long ago the offer was posted (e.g. "2h ago", "3d ago")
//   String get postedAgo {
//     final diff = DateTime.now().difference(postedAt.toDate());
//     if (diff.inMinutes < 60)  return '${diff.inMinutes}min ago';
//     if (diff.inHours  < 24)  return '${diff.inHours}h ago';
//     if (diff.inDays   < 7)   return '${diff.inDays}d ago';
//     return '${(diff.inDays / 7).floor()}w ago';
//   }
// }

// class OffersService {
//   final _db = FirebaseFirestore.instance;
//   CollectionReference<Map<String, dynamic>> get _col => _db.collection('offers');

//   /// Stream of all active offers (real-time)
//   Stream<List<OfferModel>> streamOffers({String? jobTypeFilter}) {
//     Query<Map<String, dynamic>> q = _col.where('isActive', isEqualTo: true)
//         .orderBy('postedAt', descending: true);
//     if (jobTypeFilter != null && jobTypeFilter != 'All') {
//       q = q.where('jobType', isEqualTo: jobTypeFilter);
//     }
//     return q.snapshots().map((snap) =>
//         snap.docs.map(OfferModel.fromDoc).toList());
//   }

//   /// One-time fetch
//   Future<List<OfferModel>> fetchOffers({String? jobTypeFilter}) async {
//     try {
//       Query<Map<String, dynamic>> q = _col.where('isActive', isEqualTo: true)
//           .orderBy('postedAt', descending: true);
//       if (jobTypeFilter != null && jobTypeFilter != 'All') {
//         q = q.where('jobType', isEqualTo: jobTypeFilter);
//       }
//       final snap = await q.get();
//       return snap.docs.map(OfferModel.fromDoc).toList();
//     } catch (e) {
//       debugPrint('❌ OffersService.fetchOffers: $e');
//       return [];
//     }
//   }

//   /// Post a new offer (recruteur)
//   Future<String?> createOffer(OfferModel offer) async {
//     try {
//       final ref = await _col.add(offer.toMap()..['postedAt'] = FieldValue.serverTimestamp());
//       return ref.id;
//     } catch (e) {
//       debugPrint('❌ OffersService.createOffer: $e');
//       return null;
//     }
//   }

//   /// Deactivate offer
//   Future<bool> deactivateOffer(String offerId) async {
//     try {
//       await _col.doc(offerId).update({'isActive': false});
//       return true;
//     } catch (e) {
//       debugPrint('❌ OffersService.deactivateOffer: $e');
//       return false;
//     }
//   }
// }
