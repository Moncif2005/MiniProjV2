import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'user_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  bool get isAuthenticated => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;

  Map<String, dynamic>? get userProfile {
    final user = _auth.currentUser;
    if (user == null) return null;
    return {
      'uid': user.uid,
      'email': user.email ?? '',
      'name': user.displayName ?? '',
    };
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign-in error: ${e.message}');
      return false;
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String confirmPassword,
    required String role,
  }) async {
    try {
      if (password != confirmPassword) {
        debugPrint('Sign-up error: Passwords do not match');
        return false;
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user!;

      final created = await _userService.createUser(
        uid: user.uid,
        role: role,
        email: user.email ?? email,
        displayName: name,
      );

      if (!created) {
        await user.delete();
        return false;
      }

      await user.updateDisplayName(name);
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign-up error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Unexpected error in signUp: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}