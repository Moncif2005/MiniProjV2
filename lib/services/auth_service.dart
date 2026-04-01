import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:minipr/providers/user_provider.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isAuthenticated => _auth.currentUser != null;
  String? get userId => _auth.currentUser?.uid;
  String? get userEmail => _auth.currentUser?.email;

  Map<String, dynamic>? get userProfile {
    final user = _auth.currentUser;
    if (user == null) return null;

    return {
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      // 'avatarUrl': user.photoURL,
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

  Future<bool> signUp(
    String email,
    String password,
    String name,
    String confirmPassword,
  ) async {
    try {

      if (password != confirmPassword) {
        debugPrint('Sign-up error: Passwords do not match');
        return false;
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      notifyListeners();

      userCredential.user?.updateProfile(
        displayName: name,
      );

      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Sign-up error: ${e.message}');
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }
}
