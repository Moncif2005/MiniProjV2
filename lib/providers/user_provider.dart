import 'package:flutter/material.dart';

enum UserRole { etudiant, enseignant, recruteur }

class EnrolledCourse {
  final String id;
  final String title;
  final String subtitle;
  double progress;
  EnrolledCourse({required this.id, required this.title, required this.subtitle, this.progress = 0.0});
}

class UserProvider extends ChangeNotifier {
  String   _name        = '';
  String   _email       = '';
  String   _phone       = '';
  String   _description = '';
  String   _github      = '';
  String   _linkedin    = '';
  String   _facebook    = '';
  String?  _avatarPath;
  UserRole _role        = UserRole.etudiant;

  // ── Enrolled courses (empty on new account) ──
  final List<EnrolledCourse> _enrolledCourses = [];

  // ── Getters ──
  String   get name           => _name;
  String   get email          => _email;
  String   get phone          => _phone;
  String   get description    => _description;
  String   get github         => _github;
  String   get linkedin       => _linkedin;
  String   get facebook       => _facebook;
  String?  get avatarPath     => _avatarPath;
  UserRole get role           => _role;
  List<EnrolledCourse> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  bool get hasEnrolledCourses => _enrolledCourses.isNotEmpty;

  String get roleLabel {
    switch (_role) {
      case UserRole.etudiant:    return 'Étudiant';
      case UserRole.enseignant:  return 'Enseignant';
      case UserRole.recruteur:   return 'Recruteur';
    }
  }

  String get firstName {
    if (_name.trim().isEmpty) return 'there';
    return _name.trim().split(' ').first;
  }

  String get initials {
    final parts = _name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  // ── Called on Create Account — everything starts at zero ──
  void setUser({
    required String name,
    required String email,
    required UserRole role,
  }) {
    _name        = name;
    _email       = email;
    _role        = role;
    _phone       = '';
    _description = '';
    _github      = '';
    _linkedin    = '';
    _facebook    = '';
    _avatarPath  = null;
    _enrolledCourses.clear();
    notifyListeners();
  }

  // ── Called on Save in Edit Profile ──
  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String description,
    required String github,
    required String linkedin,
    required String facebook,
    String? avatarPath,
    bool clearAvatar = false,
  }) {
    _name        = name;
    _email       = email;
    _phone       = phone;
    _description = description;
    _github      = github;
    _linkedin    = linkedin;
    _facebook    = facebook;
    if (clearAvatar) {
      _avatarPath = null;
    } else if (avatarPath != null) {
      _avatarPath = avatarPath;
    }
    notifyListeners();
  }

  // ── Enroll in a course ──
  void enrollCourse(EnrolledCourse course) {
    if (!_enrolledCourses.any((c) => c.id == course.id)) {
      _enrolledCourses.add(course);
      notifyListeners();
    }
  }

  void updateCourseProgress(String courseId, double progress) {
    final idx = _enrolledCourses.indexWhere((c) => c.id == courseId);
    if (idx != -1) {
      _enrolledCourses[idx].progress = progress;
      notifyListeners();
    }
  }

  // ── Called on Log Out ──
  void clearUser() {
    _name        = '';
    _email       = '';
    _phone       = '';
    _description = '';
    _github      = '';
    _linkedin    = '';
    _facebook    = '';
    _avatarPath  = null;
    _role        = UserRole.etudiant;
    _enrolledCourses.clear();
    notifyListeners();
  }
}
