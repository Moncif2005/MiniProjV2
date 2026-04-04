import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import 'auth/signin_screen.dart';
import 'etudiant/home_etudiant_screen.dart';
import 'enseignant/home_enseignant_screen.dart';
import 'recruteur/home_recruteur_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData && snapshot.data != null) {
          return _AuthenticatedRouter(user: snapshot.data!);
        }

        return const SignUpScreen();
      },
    );
  }
}

class _AuthenticatedRouter extends StatefulWidget {
  final User user;
  const _AuthenticatedRouter({required this.user});

  @override
  State<_AuthenticatedRouter> createState() => _AuthenticatedRouterState();
}

class _AuthenticatedRouterState extends State<_AuthenticatedRouter> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data()!;
        userProvider.setUserWithRole(
          name: data['displayName'] ?? widget.user.displayName ?? 'user',
          email: data['email'] ?? widget.user.email ?? '',
          role: _mapRoleToEnum(data['role']),
        );
      } else {
        userProvider.setUser(
          name: widget.user.displayName ?? 'user',
          email: widget.user.email ?? '',
        );
      }
    } catch (e) {
      debugPrint('❌ AuthWrapper: Error retrieving user data: $e');
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(
        name: widget.user.displayName ?? 'user',
        email: widget.user.email ?? '',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  UserRole _mapRoleToEnum(String? role) {
    switch (role?.toLowerCase()) {
      case 'enseignant': return UserRole.enseignant;
      case 'recruteur': return UserRole.recruteur;
      case 'etudiant':
      default: return UserRole.etudiant;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return _getHomeScreenByRole(context);
  }

  Widget _getHomeScreenByRole(BuildContext context) {
    final role = context.watch<UserProvider>().role;
    switch (role) {
      case UserRole.enseignant: return const HomeEnseignantScreen();
      case UserRole.recruteur: return const HomeRecruteurScreen();
      case UserRole.etudiant:
      default: return const HomeEtudiantScreen();
    }
  }
}