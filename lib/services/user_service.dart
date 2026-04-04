import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _usersRef => _db.collection('users');

  Future<bool> createUser({
    required String uid,
    required String role,
    required String email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? roleSpecificData,
  }) async {
    try {
      final defaultSettings = {
        'theme': 'system',
        'notifications': true,
        'jobNotifications': role != 'enseignant',
      };

      final defaultPrivacy = {
        'profileVisible': true,
        'showEmail': false,
        if (role == 'enseignant') 'showSpecialization': true,
      };

      final defaultStats = _getDefaultStatsByRole(role);

      final userData = <String, dynamic>{
        'uid': uid,
        'role': role,
        'email': email,
        'displayName': displayName ?? 'New user',
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'isActive': true,
        'settings': defaultSettings,
        'privacy': defaultPrivacy,
        'stats': defaultStats,
      };

      if (roleSpecificData != null) userData.addAll(roleSpecificData);

      await _usersRef.doc(uid).set(userData, SetOptions(merge: true));
      debugPrint('✅ The user document was created: $uid | role: $role');
      return true;
    } catch (e) {
      debugPrint('❌ Error creating user: $e');
      return false;
    }
  }

  Future<bool> updateProfile({
    required String uid,
    String? displayName,
    String? photoURL,
    String? bio,
    Map<String, dynamic>? additionalFields,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoURL != null) updates['photoURL'] = photoURL;
      if (bio != null) updates['bio'] = bio;
      if (additionalFields != null) updates.addAll(additionalFields);

      if (updates.isEmpty) return true;
      await _usersRef.doc(uid).update(updates);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      return false;
    }
  }

  Future<bool> updateSettings({
    required String uid,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? privacy,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (settings != null) updates['settings'] = settings;
      if (privacy != null) updates['privacy'] = privacy;
      if (updates.isEmpty) return true;

      await _usersRef.doc(uid).update(updates);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating settings: $e');
      return false;
    }
  }

  Future<bool> incrementStat({
    required String uid,
    required String statPath,
    int value = 1,
  }) async {
    try {
      await _usersRef.doc(uid).update({statPath: FieldValue.increment(value)});
      return true;
    } catch (e) {
      debugPrint('❌ Error incrementing stat: $e');
      return false;
    }
  }

  Future<bool> addCreatedResourceId({
    required String uid,
    required String resourceId,
    required String resourceType,
  }) async {
    try {
      final field = resourceType == 'course' ? 'createdCourseIds' : 'createdJobIds';
      final statPath = resourceType == 'course' ? 'stats.coursesCreated' : 'stats.jobsPosted';

      await _usersRef.doc(uid).update({
        field: FieldValue.arrayUnion([resourceId]),
        statPath: FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error adding resource ID: $e');
      return false;
    }
  }

  Future<void> updateLastLogin(String uid) async {
    await _usersRef.doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
      'isActive': true,
    });
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _usersRef.doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('❌ Error retrieving user data: $e');
      return null;
    }
  }

  Map<String, dynamic> _getDefaultStatsByRole(String role) {
    switch (role) {
      case 'etudiant':
        return {
          'enrolledCourses': 0,
          'certificates': 0,
          'jobs': {'reviewing': 0, 'interviews': 0, 'accepted': 0, 'rejected': 0},
        };
      case 'enseignant':
        return {
          'coursesCreated': 0,
          'totalStudents': 0,
          'averageRating': 0.0,
          'totalReviews': 0,
          'totalEarnings': 0.0,
        };
      case 'recruteur':
        return {
          'jobsPosted': 0,
          'activeJobs': 0,
          'totalApplicants': 0,
          'interviewsScheduled': 0,
          'hiresMade': 0,
        };
      default:
        return {};
    }
  }
}