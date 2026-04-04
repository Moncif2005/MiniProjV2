import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Firestore structure:
/// /users/{uid}/portfolio/{itemId}
///   - type: String       ('certificate' | 'formation' | 'portfolio')
///   - title: String
///   - issuer: String
///   - date: String       (display string, e.g. "January 2026" or "2020 - 2024")
///   - certId: String?    (for certificates, e.g. "UC-123456789")
///   - description: String?
///   - credentialUrl: String?
///   - thumbnailUrl: String?
///   - createdAt: Timestamp
///   - isVerified: bool   (verified by platform)

enum PortfolioItemType { certificate, formation, portfolio }

class PortfolioItem {
  final String id;
  final PortfolioItemType type;
  final String title;
  final String issuer;
  final String date;
  final String? certId;
  final String? description;
  final String? credentialUrl;
  final String? thumbnailUrl;
  final Timestamp createdAt;
  final bool isVerified;

  PortfolioItem({
    required this.id,
    required this.type,
    required this.title,
    required this.issuer,
    required this.date,
    this.certId,
    this.description,
    this.credentialUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.isVerified,
  });

  factory PortfolioItem.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PortfolioItem(
      id:            doc.id,
      type:          _parseType(d['type']),
      title:         d['title']         ?? '',
      issuer:        d['issuer']        ?? '',
      date:          d['date']          ?? '',
      certId:        d['certId'],
      description:   d['description'],
      credentialUrl: d['credentialUrl'],
      thumbnailUrl:  d['thumbnailUrl'],
      createdAt:     d['createdAt']     ?? Timestamp.now(),
      isVerified:    d['isVerified']    ?? false,
    );
  }

  static PortfolioItemType _parseType(String? s) {
    switch (s) {
      case 'formation':  return PortfolioItemType.formation;
      case 'portfolio':  return PortfolioItemType.portfolio;
      default:           return PortfolioItemType.certificate;
    }
  }

  static String typeToString(PortfolioItemType t) {
    switch (t) {
      case PortfolioItemType.formation:  return 'formation';
      case PortfolioItemType.portfolio:  return 'portfolio';
      case PortfolioItemType.certificate: return 'certificate';
    }
  }

  Map<String, dynamic> toMap() => {
    'type':          typeToString(type),
    'title':         title,
    'issuer':        issuer,
    'date':          date,
    if (certId        != null) 'certId':        certId,
    if (description   != null) 'description':   description,
    if (credentialUrl != null) 'credentialUrl': credentialUrl,
    if (thumbnailUrl  != null) 'thumbnailUrl':  thumbnailUrl,
    'createdAt':     createdAt,
    'isVerified':    isVerified,
  };
}

class CertificatesService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _db.collection('users').doc(uid).collection('portfolio');

  // ── Read ─────────────────────────────────────────────────

  /// Real-time stream of portfolio items, newest first
  Stream<List<PortfolioItem>> streamPortfolio(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PortfolioItem.fromDoc).toList());
  }

  /// Filter by type (real-time)
  Stream<List<PortfolioItem>> streamByType(String uid, PortfolioItemType type) {
    return _col(uid)
        .where('type', isEqualTo: PortfolioItem.typeToString(type))
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(PortfolioItem.fromDoc).toList());
  }

  /// One-time fetch
  Future<List<PortfolioItem>> fetchPortfolio(String uid) async {
    try {
      final snap = await _col(uid)
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map(PortfolioItem.fromDoc).toList();
    } catch (e) {
      debugPrint('❌ CertificatesService.fetchPortfolio: $e');
      return [];
    }
  }

  // ── Write ────────────────────────────────────────────────

  /// Add a new portfolio item
  Future<String?> addItem({
    required String uid,
    required PortfolioItemType type,
    required String title,
    required String issuer,
    required String date,
    String? certId,
    String? description,
    String? credentialUrl,
  }) async {
    try {
      final ref = await _col(uid).add({
        'type':          PortfolioItem.typeToString(type),
        'title':         title,
        'issuer':        issuer,
        'date':          date,
        if (certId      != null) 'certId':        certId,
        if (description != null) 'description':   description,
        if (credentialUrl != null) 'credentialUrl': credentialUrl,
        'createdAt':     FieldValue.serverTimestamp(),
        'isVerified':    false,
      });

      // Update stats
      await _db.collection('users').doc(uid).update({
        'stats.certificates': FieldValue.increment(1),
      });

      return ref.id;
    } catch (e) {
      debugPrint('❌ CertificatesService.addItem: $e');
      return null;
    }
  }

  /// Update an existing item
  Future<bool> updateItem({
    required String uid,
    required String itemId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _col(uid).doc(itemId).update(updates);
      return true;
    } catch (e) {
      debugPrint('❌ CertificatesService.updateItem: $e');
      return false;
    }
  }

  /// Delete a portfolio item
  Future<bool> deleteItem(String uid, String itemId) async {
    try {
      await _col(uid).doc(itemId).delete();
      await _db.collection('users').doc(uid).update({
        'stats.certificates': FieldValue.increment(-1),
      });
      return true;
    } catch (e) {
      debugPrint('❌ CertificatesService.deleteItem: $e');
      return false;
    }
  }

  /// Called by platform/admin to verify a certificate
  Future<void> verifyCertificate(String uid, String itemId) async {
    await _col(uid).doc(itemId).update({'isVerified': true});
  }
}
