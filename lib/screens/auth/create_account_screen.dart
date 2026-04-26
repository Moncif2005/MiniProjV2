import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/divider_with_text.dart';
import '../../widgets/profile_option_card.dart';
import '../../l10n/app_localizations.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController    = TextEditingController();
  final _emailController   = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  bool _isLoading        = false;
  int  _selectedProfile  = 0; // 0=étudiant 1=enseignant 2=recruteur
  String _confirmValue   = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);

  bool _isValidPassword(String v) =>
      v.length >= 8 &&
      RegExp(r'[A-Z]').hasMatch(v) &&
      RegExp(r'[0-9]').hasMatch(v) &&
      RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(v);

  bool _passwordsMatch() =>
      _passwordController.text == _confirmController.text;

  bool _validateAll() {
    final nameOk    = _nameController.text.trim().isNotEmpty;
    final emailOk   = _isValidEmail(_emailController.text.trim());
    final passOk    = _isValidPassword(_passwordController.text);
    final confirmOk = _confirmController.text.isNotEmpty && _passwordsMatch();
    return nameOk && emailOk && passOk && confirmOk;
  }

  Future<void> _handleCreateAccount() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).correctErrors),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService  = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final roleMap      = ['etudiant', 'enseignant', 'recruteur'];

      final ok = await authService.signUp(
        email:           _emailController.text.trim(),
        password:        _passwordController.text.trim(),
        name:            _nameController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
        role:            roleMap[_selectedProfile],
      );

      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(AppLocalizations.of(context).signUpFailed),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ));
        }
        return;
      }

      final roles = [UserRole.etudiant, UserRole.enseignant, UserRole.recruteur];
      userProvider.setUserWithRole(
        name:  _nameController.text.trim(),
        email: _emailController.text.trim(),
        role:  roles[_selectedProfile],
      );

      if (!mounted) return;
      const routes = ['/etudiant/home', '/enseignant/home', '/recruteur/home'];
      Navigator.pushNamedAndRemoveUntil(context, routes[_selectedProfile], (r) => false);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $e'), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) { if (mounted) setState(() => _isLoading = false); return; }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) throw Exception('No user returned');

      final userDoc      = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final existingRole = userDoc.data()?['role']?.toString().trim();
      final hasRole      = userDoc.exists && existingRole != null && existingRole.isNotEmpty;

      if (!hasRole) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email':     user.email ?? '',
          'name':      user.displayName ?? '',
          'firstName': (user.displayName ?? '').split(' ').first,
          'photoUrl':  user.photoURL ?? '',
          'role':      null,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (mounted) Navigator.pushReplacementNamed(context, '/choose-role', arguments: user.uid);
      } else {
        if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(e.message ?? AppLocalizations.of(context).signInFailed), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).signInFailed), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    final roleColors = [AppColors.primary, AppColors.green, AppColors.purple];

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Text(
                AppLocalizations.of(context).createAccount,
                style: TextStyle(color: c.textPrimary, fontSize: 28, fontFamily: 'Inter', fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                AppLocalizations.of(context).personalizeExperience,
                style: TextStyle(color: c.textSecondary, fontSize: 16, fontFamily: 'Inter'),
              ),
              const SizedBox(height: 32),

              // ── Role selector ──
              Text(
                AppLocalizations.of(context).chooseRole,
                style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Inter', fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ProfileOptionCard(label: AppLocalizations.of(context).roleStudent,   icon: Icons.school_rounded,             isSelected: _selectedProfile == 0, color: AppColors.primary, onTap: () => setState(() => _selectedProfile = 0))),
                  const SizedBox(width: 12),
                  Expanded(child: ProfileOptionCard(label: AppLocalizations.of(context).roleTeacher,   icon: Icons.cast_for_education_rounded, isSelected: _selectedProfile == 1, color: AppColors.green,   onTap: () => setState(() => _selectedProfile = 1))),
                  const SizedBox(width: 12),
                  Expanded(child: ProfileOptionCard(label: AppLocalizations.of(context).roleRecruiter, icon: Icons.work_rounded,               isSelected: _selectedProfile == 2, color: AppColors.purple,  onTap: () => setState(() => _selectedProfile = 2))),
                ],
              ),
              const SizedBox(height: 24),

              // ── Fields ──
              AuthTextField(
                hint: AppLocalizations.of(context).fullName,
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty) ? AppLocalizations.of(context).fullName : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(hint: AppLocalizations.of(context).emailAddress, icon: Icons.mail_outline_rounded,  controller: _emailController),
              const SizedBox(height: 16),

              AuthTextField(hint: AppLocalizations.of(context).password,        icon: Icons.lock_outline_rounded, obscure: true, controller: _passwordController),
              const SizedBox(height: 16),

              AuthTextField(
                hint: AppLocalizations.of(context).confirmPassword,
                icon: Icons.lock_outline_rounded,
                obscure: true,
                controller: _confirmController,
                validator: (_) => null,
              ),

              // ── Live password match indicator ──
              if (_confirmValue.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _passwordsMatch() ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 14,
                      color: _passwordsMatch() ? AppColors.green : AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _passwordsMatch() ? AppLocalizations.of(context).passwordsMatch : AppLocalizations.of(context).passwordsNoMatch,
                      style: TextStyle(
                        color: _passwordsMatch() ? AppColors.green : AppColors.red,
                        fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _confirmController,
                builder: (_, value, __) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _confirmValue != value.text) {
                      setState(() => _confirmValue = value.text);
                    }
                  });
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 28),

              // ── Create Account Button ──
              GestureDetector(
                onTap: _isLoading ? null : _handleCreateAccount,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: roleColors[_selectedProfile],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [BoxShadow(color: Color(0x33155DFC), blurRadius: 12, offset: Offset(0, 4))],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            AppLocalizations.of(context).createMyAccount,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              DividerWithText(label: AppLocalizations.of(context).orContinueWith),
              const SizedBox(height: 24),

              SocialButton(label: AppLocalizations.of(context).google, icon: Icons.g_mobiledata, onTap: _isLoading ? () {} : _handleGoogleSignIn),
              const SizedBox(height: 32),

              Center(
                child: RichText(
                  text: TextSpan(
                    text: '${AppLocalizations.of(context).alreadyHaveAccount} ',
                    style: TextStyle(color: c.textSecondary, fontSize: 14, fontFamily: 'Inter'),
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context).signInLink,
                        style: TextStyle(color: c.primary, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Inter'),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamedAndRemoveUntil(context, '/signup', (r) => false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorLabel extends StatelessWidget {
  final String text;
  const _ErrorLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 13),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.red, fontSize: 12, fontFamily: 'Inter', fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
