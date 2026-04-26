import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/divider_with_text.dart';
import '../../l10n/app_localizations.dart';

// Class is named SignUpScreen to match the '/signup' route and auth_wrapper reference
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateAll() {
    final emailRegex = RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$');
    final password = _passwordController.text;
    if (!emailRegex.hasMatch(_emailController.text)) return false;
    if (password.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(password)) return false;
    if (!RegExp(r'[0-9]').hasMatch(password)) return false;
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(password)) return false;
    return true;
  }

  Future<void> _handleSignIn() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).fixErrors),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final ok = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).welcomeBackEmoji),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).signInFailed),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();

      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user == null) throw Exception('Firebase sign-in returned no user');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final existingRole = userDoc.data()?['role']?.toString().trim();
      final hasRole =
          userDoc.exists && existingRole != null && existingRole.isNotEmpty;

      if (!hasRole) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': user.email ?? '',
          'name': user.displayName ?? '',
          'firstName': (user.displayName ?? '').split(' ').first,
          'photoUrl': user.photoURL ?? '',
          'role': null,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/choose-role',
            arguments: user.uid,
          );
        }
        return;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).welcomeBackEmoji),
            backgroundColor: AppColors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message ?? AppLocalizations.of(context).signInFailed,
            ),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).signInFailed),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Logo ──
              Center(
                child: Image.asset(
                  'images/logo.png',
                  width: 310,
                  height: 124,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 64),
                ),
              ),
              const SizedBox(height: 16),

              Center(
                child: Text(
                  AppLocalizations.of(context).welcomeBack,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppLocalizations.of(context).platformSubtitle,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              AuthTextField(
                hint: AppLocalizations.of(context).emailAddress,
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                hint: AppLocalizations.of(context).password,
                icon: Icons.lock_outline,
                obscure: true,
                hideStrength: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/forgot-password'),
                  child: Text(
                    AppLocalizations.of(context).forgotPassword,
                    style: TextStyle(
                      color: c.primary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primaryLight,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          AppLocalizations.of(context).signIn,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              DividerWithText(
                label: AppLocalizations.of(context).orContinueWith,
              ),
              const SizedBox(height: 16),

              SocialButton(
                label: AppLocalizations.of(context).google,
                icon: Icons.g_mobiledata,
                onTap: _handleGoogleSignIn,
              ),
              const SizedBox(height: 24),

              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${AppLocalizations.of(context).newToApp} ',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: AppLocalizations.of(context).createAccount,
                        style: TextStyle(
                          color: c.primary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () =>
                              Navigator.pushNamed(context, '/create-account'),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
