import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final fbUser = snapshot.data!;
          final userProvider =
              Provider.of<UserProvider>(context, listen: false);

          // Sync name/email from Firebase if not yet set
          if (userProvider.name.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              userProvider.setUser(
                name: fbUser.displayName ?? '',
                email: fbUser.email ?? '',
              );
            });
          }

          // Route to role-based home screen
          switch (userProvider.role) {
            case UserRole.enseignant:
              return const HomeEnseignantScreen();
            case UserRole.recruteur:
              return const HomeRecruteurScreen();
            case UserRole.etudiant:
            default:
              return const HomeEtudiantScreen();
          }
        }

        // Not logged in → sign-in screen
        return const SignUpScreen();
      },
    );
  }
}
