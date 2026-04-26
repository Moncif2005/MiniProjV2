// lib/utils/route_guard.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RouteGuard {
  static bool canAccessProtectedRoute(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must log in first.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }
  
  static void navigateToProtected(
    BuildContext context, 
    String route,
  ) {
    if (canAccessProtectedRoute(context)) {
      Navigator.pushNamed(context, route);
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context, 
        '/signup', 
        (r) => false,
      );
    }
  }
}