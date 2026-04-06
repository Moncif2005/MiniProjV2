import 'package:flutter/material.dart';

enum UserRole { etudiant, enseignant, recruteur }

class EnrolledCourse {
  final String id;
  final String title;
  final String subtitle;
  double progress;
  EnrolledCourse({
    required this.id,
    required this.title,
    required this.subtitle,
    this.progress = 0.0,
  });
}

class UserProvider extends ChangeNotifier {
  // ── Basic Info ──
  String _name = '';
  String _email = '';
  String? _uid;
  String? _avatarPath; // photoURL from Firestore
  String _bio = '';
  String _phone = '';
  String _github = '';
  String _linkedin = '';
  String _facebook = '';
  UserRole _role = UserRole.etudiant;

  // ── Settings & Privacy (from Firestore) ──
  String _theme = 'system';
  bool _notificationsEnabled = true;
  bool _jobNotifications = true;
  bool _profileVisible = true;
  bool _showEmail = false;

  // ── Stats (from Firestore) ──
  int _courses = 0;
  int _points = 0;
  int _projects = 0;
  int _enrolledCoursesCount = 0;
  int _completedCoursesCount = 0;
  int _certificatesCount = 0;
  int _streakDays = 0;
  int _totalLearningMinutes = 0;
  
  // Role-specific stats
  int _coursesCreated = 0;
  int _totalStudents = 0;
  double _averageRating = 0.0;
  int _jobsPosted = 0;
  int _totalApplicants = 0;

  // ── Local enrolled courses list ──
  final List<EnrolledCourse> _enrolledCourses = [];

  // ── Getters ──
  String get name => _name;
  String get email => _email;
  String? get uid => _uid;
  String? get avatarPath => _avatarPath;
  String get bio => _bio;
  String get phone => _phone;
  String get github => _github;
  String get linkedin => _linkedin;
  String get facebook => _facebook;
  UserRole get role => _role;
  
  // Settings & Privacy getters
  String get theme => _theme;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get jobNotifications => _jobNotifications;
  bool get profileVisible => _profileVisible;
  bool get showEmail => _showEmail;
  
  // Stats getters
  int get courses => _courses;
  int get points => _points;
  int get projects => _projects;
  int get enrolledCoursesCount => _enrolledCoursesCount;
  int get completedCoursesCount => _completedCoursesCount;
  int get certificatesCount => _certificatesCount;
  int get streakDays => _streakDays;
  int get totalLearningMinutes => _totalLearningMinutes;
  int get coursesCreated => _coursesCreated;
  int get totalStudents => _totalStudents;
  double get averageRating => _averageRating;
  int get jobsPosted => _jobsPosted;
  int get totalApplicants => _totalApplicants;

  List<EnrolledCourse> get enrolledCourses => List.unmodifiable(_enrolledCourses);
  bool get hasEnrolledCourses => _enrolledCourses.isNotEmpty;

  String get roleLabel {
    switch (_role) {
      case UserRole.etudiant: return 'Étudiant';
      case UserRole.enseignant: return 'Enseignant';
      case UserRole.recruteur: return 'Recruteur';
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

  // ── 🚀 NEW: Update ALL fields from Firestore document ──
  void updateFromFirestore(Map<String, dynamic> data) {
    // Basic info
    _uid = data['uid'] ?? _uid;
    _name = data['displayName'] ?? _name;
    _email = data['email'] ?? _email;
    _avatarPath = data['photoURL'];
    _bio = data['bio'] ?? '';
    _phone = data['phone'] ?? '';
    _github = data['github'] ?? '';
    _linkedin = data['linkedin'] ?? '';
    _facebook = data['facebook'] ?? '';
    
    final roleStr = data['role']?.toString().toLowerCase();
    switch (roleStr) {
      case 'enseignant': _role = UserRole.enseignant; break;
      case 'recruteur': _role = UserRole.recruteur; break;
      default: _role = UserRole.etudiant;
    }

    // Settings & Privacy
    final settings = data['settings'] as Map<String, dynamic>?;
    if (settings != null) {
      _theme = settings['theme'] ?? _theme;
      _notificationsEnabled = settings['notifications'] ?? _notificationsEnabled;
      _jobNotifications = settings['jobNotifications'] ?? _jobNotifications;
    }
    final privacy = data['privacy'] as Map<String, dynamic>?;
    if (privacy != null) {
      _profileVisible = privacy['profileVisible'] ?? _profileVisible;
      _showEmail = privacy['showEmail'] ?? _showEmail;
    }

    // Stats
    final stats = data['stats'] as Map<String, dynamic>?;
    if (stats != null) {
      _enrolledCoursesCount = stats['enrolledCourses'] ?? _enrolledCoursesCount;
      _completedCoursesCount = stats['completedCourses'] ?? _completedCoursesCount;
      _certificatesCount = stats['certificates'] ?? _certificatesCount;
      _streakDays = stats['streakDays'] ?? _streakDays;
      _totalLearningMinutes = stats['totalLearningMinutes'] ?? _totalLearningMinutes;
      _coursesCreated = stats['coursesCreated'] ?? _coursesCreated;
      _totalStudents = stats['totalStudents'] ?? _totalStudents;
      _averageRating = (stats['averageRating'] ?? _averageRating).toDouble();
      _jobsPosted = stats['jobsPosted'] ?? _jobsPosted;
      _totalApplicants = stats['totalApplicants'] ?? _totalApplicants;
    }

    notifyListeners();
  }

  // ── Called by AuthWrapper (backward compatible) ──
  void setUser({
    required String name,
    required String email,
    String? uid,
    String? avatarPath,
  }) {
    _name = name;
    _email = email;
    if (uid != null) _uid = uid;
    if (avatarPath != null) _avatarPath = avatarPath;
    notifyListeners();
  }

  // ── Called by CreateAccountScreen (backward compatible) ──
  void setUserWithRole({
    required String name,
    required String email,
    required UserRole role,
    String? uid,
    String? avatarPath,
  }) {
    _name = name;
    _email = email;
    _role = role;
    if (uid != null) _uid = uid;
    if (avatarPath != null) _avatarPath = avatarPath;
    // Reset stats on new account
    _courses = 0; _points = 0; _projects = 0;
    _phone = ''; _bio = ''; _github = ''; _linkedin = ''; _facebook = '';
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
    _name = name;
    _email = email;
    _phone = phone;
    _bio = description; // description in UI = bio in Firestore
    _github = github;
    _linkedin = linkedin;
    _facebook = facebook;
    if (clearAvatar) {
      _avatarPath = null;
    } else if (avatarPath != null) {
      _avatarPath = avatarPath;
    }
    notifyListeners();
  }

  // ── Course progress (local only) ──
  void incrementCourses() { _courses++; notifyListeners(); }

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
    _name = ''; _email = ''; _phone = ''; _bio = '';
    _github = ''; _linkedin = ''; _facebook = '';
    _avatarPath = null; _uid = null;
    _role = UserRole.etudiant;
    _courses = 0; _points = 0; _projects = 0;
    _enrolledCoursesCount = 0; _completedCoursesCount = 0;
    _certificatesCount = 0; _streakDays = 0; _totalLearningMinutes = 0;
    _coursesCreated = 0; _totalStudents = 0; _averageRating = 0.0;
    _jobsPosted = 0; _totalApplicants = 0;
    _enrolledCourses.clear();
    notifyListeners();
  }
}