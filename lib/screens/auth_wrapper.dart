import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:minipr/providers/user_provider.dart';
import 'package:minipr/screens/auth/signin_screen.dart';
import 'package:minipr/screens/home/home_screen.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

const _protectedRoutes = [
  '/home',
  '/offers',
  '/learn',
  '/lesson',
  '/notifications',
  '/profile',
  '/edit-profile',
  '/certificates',
  '/applied-jobs',
  '/settings',
  '/learning-history',
];

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        
        if (snapshot.hasData) {
          final authService = Provider.of<AuthService>(context, listen: false);
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          
          final user = snapshot.data;
          if (user != null) {
            userProvider.setUser(
              name: user.displayName ?? 'User',
              email: user.email ?? '',
            );
          }
          
          return HomeScreen();
        }
        
        return SignUpScreen();
      },
    );
  }
}