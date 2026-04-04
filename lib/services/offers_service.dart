import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /offers/{offerId}
///   - title: String
///   - company: String
///   - companyInitial: String
///   - companyBgColor: int (Color.value)
///   - companyColor: int (Color.value)
///   - location: String
///   - postedAt: Timestamp
///   - salary: String
///   - jobType: String  ('Full-time' | 'Freelance' | 'Contract' | 'Remote')
///   - isActive: bool
///   - description: String
///   - recruiterId: String (uid of the recruteur who posted it)

class OfferModel {
  final String id;
  final String title;
  final String company;
  final String companyInitial;
  final int companyBgColor;
  final int companyColor;
  final String location;
  final Timestamp postedAt;
  final String salary;
  final String jobType;
  final bool isActive;
  final String description;
  final String recruiterId;

  OfferModel({
    required this.id,
    required this.title,
    required this.company,
    required this.companyInitial,
    required this.companyBgColor,
    required this.companyColor,
    required this.location,
    required this.postedAt,
    required this.salary,
    required this.jobType,
    required this.isActive,
    required this.description,
    required this.recruiterId,
  });

  factory OfferModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return OfferModel(
      id:              doc.id,
      title:           d['title']          ?? '',
      company:         d['company']        ?? '',
      companyInitial:  d['companyInitial'] ?? '',
      companyBgColor:  d['companyBgColor'] ?? 0xFFE0E7FF,
      companyColor:    d['companyColor']   ?? 0xFF4F39F6,
      location:        d['location']       ?? '',
      postedAt:        d['postedAt']       ?? Timestamp.now(),
      salary:          d['salary']         ?? '',
      jobType:         d['jobType']        ?? 'Full-time',
      isActive:        d['isActive']       ?? true,
      description:     d['description']   ?? '',
      recruiterId:     d['recruiterId']    ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'title':          title,
    'company':        company,
    'companyInitial': companyInitial,
    'companyBgColor': companyBgColor,
    'companyColor':   companyColor,
    'location':       location,
    'postedAt':       postedAt,
    'salary':         salary,
    'jobType':        jobType,
    'isActive':       isActive,
    'description':    description,
    'recruiterId':    recruiterId,
  };

  /// How long ago the offer was posted (e.g. "2h ago", "3d ago")
  String get postedAgo {
    final diff = DateTime.now().difference(postedAt.toDate());
    if (diff.inMinutes < 60)  return '${diff.inMinutes}min ago';
    if (diff.inHours  < 24)  return '${diff.inHours}h ago';
    if (diff.inDays   < 7)   return '${diff.inDays}d ago';
    return '${(diff.inDays / 7).floor()}w ago';
  }
}

class OffersService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col => _db.collection('offers');

  /// Stream of all active offers (real-time)
  Stream<List<OfferModel>> streamOffers({String? jobTypeFilter}) {
    Query<Map<String, dynamic>> q = _col.where('isActive', isEqualTo: true)
        .orderBy('postedAt', descending: true);
    if (jobTypeFilter != null && jobTypeFilter != 'All') {
      q = q.where('jobType', isEqualTo: jobTypeFilter);
    }
    return q.snapshots().map((snap) =>
        snap.docs.map(OfferModel.fromDoc).toList());
  }

  /// One-time fetch
  Future<List<OfferModel>> fetchOffers({String? jobTypeFilter}) async {
    try {
      Query<Map<String, dynamic>> q = _col.where('isActive', isEqualTo: true)
          .orderBy('postedAt', descending: true);
      if (jobTypeFilter != null && jobTypeFilter != 'All') {
        q = q.where('jobType', isEqualTo: jobTypeFilter);
      }
      final snap = await q.get();
      return snap.docs.map(OfferModel.fromDoc).toList();
    } catch (e) {
      debugPrint('❌ OffersService.fetchOffers: $e');
      return [];
    }
  }

  /// Post a new offer (recruteur)
  Future<String?> createOffer(OfferModel offer) async {
    try {
      final ref = await _col.add(offer.toMap()..['postedAt'] = FieldValue.serverTimestamp());
      return ref.id;
    } catch (e) {
      debugPrint('❌ OffersService.createOffer: $e');
      return null;
    }
  }

  /// Deactivate offer
  Future<bool> deactivateOffer(String offerId) async {
    try {
      await _col.doc(offerId).update({'isActive': false});
      return true;
    } catch (e) {
      debugPrint('❌ OffersService.deactivateOffer: $e');
      return false;
    }
  }
}
