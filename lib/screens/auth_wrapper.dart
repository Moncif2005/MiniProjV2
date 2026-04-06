import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'auth/signin_screen.dart';
import 'etudiant/home_etudiant_screen.dart';
import 'enseignant/home_enseignant_screen.dart';
import 'recruteur/home_recruteur_screen.dart';

// ✅ استخدم StatefulWidget لضمان استجابة فورية
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      debugPrint('🔄 AuthWrapper Listener: user=${user?.uid ?? 'null'}');
      if (mounted) {
        // ✅ setState هنا يجبر التطبيق على إعادة الرسم فوراً
        setState(() => _currentUser = user);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      '🎨 AuthWrapper build: currentUser=${_currentUser?.uid ?? 'null'}',
    );

    // ✅ إذا لم يوجد مستخدم، اعرض صفحة الدخول
    if (_currentUser == null) {
      return const SignUpScreen();
    }

    // ✅ إذا وجد مستخدم، اعرض الشاشة المناسبة بناءً على الدور
    // ✅ ValueKey يضمن إعادة تحميل البيانات إذا تغير المستخدم
    return _AuthenticatedRouter(
      key: ValueKey(_currentUser!.uid),
      user: _currentUser!,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// كلاس التوجيه الداخلي
// ─────────────────────────────────────────────────────────────────────────────
class _AuthenticatedRouter extends StatefulWidget {
  final User user;
  const _AuthenticatedRouter({super.key, required this.user});

  @override
  State<_AuthenticatedRouter> createState() => _AuthenticatedRouterState();
}

class _AuthenticatedRouterState extends State<_AuthenticatedRouter> {
  bool _isLoading = true;
  UserRole? _finalRole;

  @override
  void initState() {
    super.initState();
    debugPrint('🚀 Router Init: ${widget.user.uid}');
    _loadAndRoute();
  }

  Future<void> _loadAndRoute() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      debugPrint(
        '📄 Firestore: exists=${doc.exists}, role=${doc.data()?['role']}',
      );

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final r = data['role']?.toString().toLowerCase().trim();
        switch (r) {
          case 'enseignant':
            _finalRole = UserRole.enseignant;
            break;
          case 'recruteur':
            _finalRole = UserRole.recruteur;
            break;
          default:
            _finalRole = UserRole.etudiant;
        }
        userProvider.setUserWithRole(
          uid: widget.user.uid,
          name: data['displayName'] ?? 'User',
          email: data['email'] ?? '',
          role: _finalRole!,
        );
      } else {
        _finalRole = UserRole.etudiant;
        userProvider.setUser(uid: widget.user.uid, name: 'User', email: '');
      }
    } catch (e) {
      debugPrint('❌ Router Error: $e');
      _finalRole = UserRole.etudiant;
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    debugPrint('🎯 Routing to: $_finalRole');
    switch (_finalRole) {
      case UserRole.enseignant:
        return const HomeEnseignantScreen();
      case UserRole.recruteur:
        return const HomeRecruteurScreen();
      default:
        return const HomeEtudiantScreen();
    }
  }
}
