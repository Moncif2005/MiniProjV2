import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:minipr/screens/enseignant/enseignant_home_screen.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../services/fcm_service.dart';
import '../theme/app_colors.dart';
import 'auth/signin_screen.dart';
import 'auth/choose_role_screen.dart';
import 'etudiant/home_etudiant_screen.dart';
import 'recruteur/home_recruteur_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  User? _currentUser;
  late StreamSubscription<User?> _authSubscription;

  @override
  void initState() {
    super.initState();
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (mounted) setState(() => _currentUser = user);
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. إذا لم يكن مسجلاً، اذهب للتسجيل
    if (_currentUser == null) {
      return const SignUpScreen();
    }

    // 2. إذا كان مسجلاً، انتظر تحميل بياناته ثم وجهه
    return _AuthenticatedRouter(user: _currentUser!);
  }
}

class _AuthenticatedRouter extends StatefulWidget {
  final User user;
  const _AuthenticatedRouter({super.key, required this.user});

  @override
  State<_AuthenticatedRouter> createState() => _AuthenticatedRouterState();
}

class _AuthenticatedRouterState extends State<_AuthenticatedRouter> {
  bool _isLoading = true;
  UserRole? _role;
  bool _needsRole = false; // true → user has no role yet

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        userProvider.updateFromFirestore(data);
        final r = data['role']?.toString().toLowerCase().trim();

        // ✅ Fix 1 & 5: check role explicitly, not just doc.exists
        if (r == null || r.isEmpty) {
          _needsRole = true; // doc exists but role was never set (glitch/crash)
        } else if (r == 'enseignant') {
          _role = UserRole.enseignant;
        } else if (r == 'recruteur') {
          _role = UserRole.recruteur;
        } else {
          _role = UserRole.etudiant;
        }
      } else {
        // No doc at all → needs role selection
        _needsRole = true;
      }
    } catch (e) {
      debugPrint('AuthWrapper load error: $e');
      _role = UserRole.etudiant;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        // ignore: use_build_context_synchronously
        FcmService.instance.init(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const _BrandedLoadingScreen();
    }

    // ✅ Fix 5: AuthWrapper itself handles role=null → ChooseRoleScreen
    if (_needsRole) {
      return ChooseRoleScreen(uid: widget.user.uid);
    }

    switch (_role) {
      case UserRole.enseignant:
        return const EnseignantHomeScreen();
      case UserRole.recruteur:
        return const HomeRecruteurScreen();
      default:
        return const HomeEtudiantScreen();
    }
  }
}


// ── Branded loading screen shown while resolving user role ─────────────────
class _BrandedLoadingScreen extends StatefulWidget {
  const _BrandedLoadingScreen();

  @override
  State<_BrandedLoadingScreen> createState() => _BrandedLoadingScreenState();
}

class _BrandedLoadingScreenState extends State<_BrandedLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: AppColors.gradientBlue,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:provider/provider.dart';

// import '../providers/user_provider.dart';
// import 'auth/signin_screen.dart';
// import 'etudiant/home_etudiant_screen.dart';
// import 'enseignant/trash/home_enseignant_screen.dart';
// import 'recruteur/home_recruteur_screen.dart';

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   User? _currentUser;
//   StreamSubscription<User?>? _authSubscription;

//   @override
//   void initState() {
//     super.initState();
//     _startListening();
//   }

//   void _startListening() {
//     _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
//       debugPrint('🔄 AuthWrapper Listener: user=${user?.uid ?? 'null'}');
//       if (mounted) setState(() => _currentUser = user);
//     });
//   }

//   @override
//   void dispose() {
//     _authSubscription?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('🎨 AuthWrapper build: currentUser=${_currentUser?.uid ?? 'null'}');
    
//     if (_currentUser == null) {
//       return const SignUpScreen();
//     }
    
//     return _AuthenticatedRouter(
//       key: ValueKey(_currentUser!.uid),
//       user: _currentUser!,
//     );
//   }
// }

// class _AuthenticatedRouter extends StatefulWidget {
//   final User user;
//   const _AuthenticatedRouter({super.key, required this.user});

//   @override
//   State<_AuthenticatedRouter> createState() => _AuthenticatedRouterState();
// }

// class _AuthenticatedRouterState extends State<_AuthenticatedRouter> {
//   bool _isLoading = true;
//   UserRole? _finalRole;

//   @override
//   void initState() {
//     super.initState();
//     debugPrint('🚀 Router Init: ${widget.user.uid}');
//     _loadAndRoute();
//   }

//   Future<void> _loadAndRoute() async {
//     try {
//       final userProvider = Provider.of<UserProvider>(context, listen: false);
      
//       final doc = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(widget.user.uid)
//           .get();

//       debugPrint('📄 Firestore: exists=${doc.exists}');

//       if (doc.exists && doc.data() != null) {
//         final data = doc.data()!;
        
//         // ✅ 🚀 الجديد: تحديث كل الحقول دفعة واحدة
//         userProvider.updateFromFirestore(data);
        
//         // تحديد الدور للتوجيه
//         final r = data['role']?.toString().toLowerCase().trim();
//         switch (r) {
//           case 'enseignant': _finalRole = UserRole.enseignant; break;
//           case 'recruteur':  _finalRole = UserRole.recruteur; break;
//           default:           _finalRole = UserRole.etudiant;
//         }
        
//         debugPrint('✅ Full profile loaded for ${widget.user.uid}');
//         debugPrint('🖼️ photoURL: ${data['photoURL']}');
//         debugPrint('📱 phone: ${data['phone']}');
//         debugPrint('🔗 github: ${data['github']}');
//       } else {
//         debugPrint('⚠️ Fallback: Firestore doc missing');
//         _finalRole = UserRole.etudiant;
//         userProvider.setUser(
//           uid: widget.user.uid,
//           name: widget.user.displayName ?? 'User',
//           email: widget.user.email ?? '',
//         );
//       }
//     } catch (e, st) {
//       debugPrint('❌ Router Error: $e\n$st');
//       _finalRole = UserRole.etudiant;
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Scaffold(body: Center(child: CircularProgressIndicator()));
//     }

//     debugPrint('🎯 Routing to: $_finalRole');
//     switch (_finalRole) {
//       case UserRole.enseignant: return const HomeEnseignantScreen();
//       case UserRole.recruteur:  return const HomeRecruteurScreen();
//       default:                  return const HomeEtudiantScreen();
//     }
//   }
// }