import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/divider_with_text.dart';
import '../../widgets/profile_option_card.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController     = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();

  int _selectedProfile = 0; // 0=étudiant, 1=enseignant, 2=recruteur

  bool _nameError       = false;
  bool _emailError      = false;
  bool _passwordError   = false;
  bool _confirmError    = false;
  bool _confirmMismatch = false;

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
    final nameOk     = _nameController.text.trim().isNotEmpty;
    final emailOk    = _isValidEmail(_emailController.text.trim());
    final passwordOk = _isValidPassword(_passwordController.text);
    final confirmOk  = _confirmController.text.isNotEmpty && _passwordsMatch();

    setState(() {
      _nameError       = !nameOk;
      _emailError      = !emailOk;
      _passwordError   = !passwordOk;
      _confirmError    = !confirmOk;
      _confirmMismatch = _confirmController.text.isNotEmpty && !_passwordsMatch();
    });

    return nameOk && emailOk && passwordOk && confirmOk;
  }

  void _handleCreateAccount() {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final roles = [UserRole.etudiant, UserRole.enseignant, UserRole.recruteur];
    context.read<UserProvider>().setUser(
      name:  _nameController.text.trim(),
      email: _emailController.text.trim(),
      role:  roles[_selectedProfile],
    );

    final routes = ['/etudiant/home', '/enseignant/home', '/recruteur/home'];
    Navigator.pushNamedAndRemoveUntil(
        context, routes[_selectedProfile], (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Back button ──
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38, height: 38,
                  decoration: ShapeDecoration(
                    color: c.bg,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 1.24, color: c.border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: c.textPrimary),
                ),
              ),
              const SizedBox(height: 24),

              Text('Create Account',
                  style: TextStyle(
                    color: c.textPrimary, fontSize: 28,
                    fontFamily: 'Inter', fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 6),
              Text('Join Formanova today',
                  style: TextStyle(
                    color: c.textSecondary, fontSize: 16, fontFamily: 'Inter',
                  )),
              const SizedBox(height: 32),

              // ── Profile Type ──
              Text('I am a...',
                  style: TextStyle(
                    color: c.textPrimary, fontSize: 16,
                    fontFamily: 'Inter', fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Étudiant',
                      icon: Icons.school_rounded,
                      isSelected: _selectedProfile == 0,
                      color: AppColors.primary,
                      onTap: () => setState(() => _selectedProfile = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Enseignant',
                      icon: Icons.cast_for_education_rounded,
                      isSelected: _selectedProfile == 1,
                      color: AppColors.green,
                      onTap: () => setState(() => _selectedProfile = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Recruteur',
                      icon: Icons.work_rounded,
                      isSelected: _selectedProfile == 2,
                      color: AppColors.purple,
                      onTap: () => setState(() => _selectedProfile = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Name ──
              if (_nameError) ...[
                const _ErrorLabel(text: 'Le nom est requis'),
                const SizedBox(height: 4),
              ],
              AuthTextField(
                hint: 'Full Name',
                label: 'Full Name',
                prefixIcon: Icons.person_outline_rounded,
                controller: _nameController,
                hasError: _nameError,
                errorMessage: 'Le nom est requis',
                onChanged: (_) => setState(() => _nameError = false),
              ),
              const SizedBox(height: 16),

              // ── Email ──
              AuthTextField(
                hint: 'Email address',
                label: 'Email',
                prefixIcon: Icons.mail_outline_rounded,
                controller: _emailController,
                hasError: _emailError,
                errorMessage: 'Entrez un email valide',
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => setState(() => _emailError = false),
              ),
              const SizedBox(height: 16),

              // ── Password ──
              AuthTextField(
                hint: 'Password',
                label: 'Password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _passwordController,
                isPassword: true,
                showStrengthIndicator: true,
                hasError: _passwordError,
                errorMessage: 'Mot de passe trop faible',
                onChanged: (_) => setState(() => _passwordError = false),
              ),
              const SizedBox(height: 16),

              // ── Confirm Password ──
              AuthTextField(
                hint: 'Confirm Password',
                label: 'Confirm Password',
                prefixIcon: Icons.lock_outline_rounded,
                controller: _confirmController,
                isPassword: true,
                hideStrength: true,
                hasError: _confirmError,
                errorMessage: _confirmMismatch
                    ? 'Les mots de passe ne correspondent pas'
                    : 'Confirmez votre mot de passe',
                onChanged: (_) => setState(() {
                  _confirmError    = false;
                  _confirmMismatch = false;
                }),
              ),
              const SizedBox(height: 32),

              // ── Create Button ──
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _handleCreateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: [
                      AppColors.primary,
                      AppColors.green,
                      AppColors.purple,
                    ][_selectedProfile],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Create Account',
                      style: TextStyle(
                        fontSize: 16, fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      )),
                ),
              ),
              const SizedBox(height: 24),

              const DividerWithText(label: 'Or continue with'),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SocialButton(
                      label: 'Github',
                      icon: Icons.code,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: c.textSecondary, fontSize: 14, fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign In',
                        style: TextStyle(
                          color: c.primary, fontWeight: FontWeight.w700,
                          fontFamily: 'Inter',
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
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
        const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 14),
        const SizedBox(width: 4),
        Text(text,
            style: const TextStyle(
              color: AppColors.red, fontSize: 12, fontFamily: 'Inter',
            )),
      ],
    );
  }
}
