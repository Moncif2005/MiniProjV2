import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name        = '';
  String _email       = '';
  String _phone       = '';
  String _description = '';
  String _github      = '';
  String _linkedin    = '';
  String _facebook    = '';
  String? _avatarPath;

  // ── Stats ──
  int _courses  = 0;
  int _points   = 0;
  int _projects = 0;

  // ── Getters ──
  String  get name        => _name;
  String  get email       => _email;
  String  get phone       => _phone;
  String  get description => _description;
  String  get github      => _github;
  String  get linkedin    => _linkedin;
  String  get facebook    => _facebook;
  String? get avatarPath  => _avatarPath;
  int     get courses     => _courses;
  int     get points      => _points;
  int     get projects    => _projects;

  // ── Derived ──
  String get firstName {
    if (_name.trim().isEmpty) { return 'there'; }
    return _name.trim().split(' ').first;
  }

  String get initials {
    final parts = _name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) { return 'U'; }
    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  // ── Called on Create Account — everything starts at 0 ──
  void setUser({required String name, required String email}) {
    _name     = name;
    _email    = email;
    _courses  = 0;
    _points   = 0;
    _projects = 0;
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
  }) {
    _name        = name;
    _email       = email;
    _phone       = phone;
    _description = description;
    _github      = github;
    _linkedin    = linkedin;
    _facebook    = facebook;
    if (avatarPath != null) {
      _avatarPath = avatarPath;
    }
    notifyListeners();
  }

  // ── Called when user completes a course ──
  void incrementCourses() {
    _courses++;
    notifyListeners();
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
    _courses     = 0;
    _points      = 0;
    _projects    = 0;
    notifyListeners();
  }
}