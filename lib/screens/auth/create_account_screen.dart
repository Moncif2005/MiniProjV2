import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:minipr/services/auth_service.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _isLoading = false;

  int _selectedProfile = 0;

  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmError = false;
  bool _confirmMismatch = false;
  String _confirmValue = '';

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

  bool _passwordsMatch() => _passwordController.text == _confirmController.text;

  bool _validateAll() {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final emailOk = _isValidEmail(_emailController.text.trim());
    final passwordOk = _isValidPassword(_passwordController.text);
    final confirmOk = _confirmController.text.isNotEmpty && _passwordsMatch();

    setState(() {
      _nameError = !nameOk;
      _emailError = !emailOk;
      _passwordError = !passwordOk;
      _confirmError = !confirmOk;
      _confirmMismatch =
          _confirmController.text.isNotEmpty && !_passwordsMatch();
    });

    return nameOk && emailOk && passwordOk && confirmOk;
  }

  Future<void> _handleCreateAccount() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the errors'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthService authService = Provider.of<AuthService>(
        context,
        listen: false,
      );
      final UserProvider userProvider = Provider.of<UserProvider>(
        context,
        listen: false,
      );

      final response = await AuthService().signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(),
        _confirmController.text.trim(),
      );
      if (response) {
        final user = authService.userProfile;
        print(user);
        if (user != null) {
          userProvider.setUser(
            name: user['name'] ?? _nameController.text.trim(),
            email: user['email'] ?? _emailController.text.trim(),
          );
        }
        if (_selectedProfile == 0) {
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _selectedProfile == 1
                      ? 'Teacher area coming soon!'
                      : 'Recruiter area coming soon!',
                ),
                backgroundColor: AppColors.lightTextSecondary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Sign up failed. Please check your information."),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isStudent = _selectedProfile == 0;

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
                'Create an account',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 28,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Join Formanova today and start your learning journey!",
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),

              // ── Profile Type ──
              Text(
                'I am a:',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Student',
                      icon: Icons.school_rounded,
                      isSelected: _selectedProfile == 0,
                      color: AppColors.primary,
                      onTap: () => setState(() => _selectedProfile = 0),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Teacher',
                      icon: Icons.cast_for_education_rounded,
                      isSelected: _selectedProfile == 1,
                      color: AppColors.green,
                      onTap: () => setState(() => _selectedProfile = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ProfileOptionCard(
                      label: 'Recruiter',
                      icon: Icons.work_rounded,
                      isSelected: _selectedProfile == 2,
                      color: AppColors.purple,
                      onTap: () => setState(() => _selectedProfile = 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Coming Soon Banner ──
              if (!isStudent) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEFCE8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFDE68A),
                      width: 1.24,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD08700),
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _selectedProfile == 1
                              ? "The Teacher area will be available soon! Limited access."
                                    "Available. Limited access."
                              : "The Recruiter area will be available soon! Limited access."
                                    "Available. Limited access.",
                          style: const TextStyle(
                            color: Color(0xFFD08700),
                            fontSize: 12,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // ── Name ──
              // if (_nameError) ...[
              //   const _ErrorLabel(text: 'Le nom est requis'),
              //   const SizedBox(height: 4),
              // ],
              AuthTextField(
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              // ── Email ──
              // if (_emailError) ...[
              //   const _ErrorLabel(text: 'Email invalide'),
              //   const SizedBox(height: 4),
              // ],
              AuthTextField(
                hint: 'Email Address',
                icon: Icons.mail_outline_rounded,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              // ── Password ──
              // if (_passwordError) ...[
              //   const _ErrorLabel(
              //       text: 'Min. 8 car., 1 maj.,'
              //           ' 1 chiffre, 1 symbole'),
              //   const SizedBox(height: 4),
              // ],
              AuthTextField(
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),

              // ── Confirm Password ──
              // if (_confirmError) ...[
              //   _ErrorLabel(
              //       text: _confirmMismatch
              //           ? 'Les mots de passe ne correspondent pas'
              //           : 'Veuillez confirmer votre mot de passe'),
              //   const SizedBox(height: 4),
              // ],
              AuthTextField(
                hint: 'Confirm Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                controller: _confirmController,
                validator: (_) => null,
              ),

              // ── Live match indicator ──
              if (_confirmValue.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _passwordsMatch()
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 14,
                      color: _passwordsMatch()
                          ? AppColors.green
                          : AppColors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _passwordsMatch()
                          ? 'The passwords match'
                          : 'The passwords do not match',
                      style: TextStyle(
                        color: _passwordsMatch()
                            ? AppColors.green
                            : AppColors.red,
                        fontSize: 12,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],

              // ── Confirm listener ──
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
                    color: isStudent ? AppColors.primary : c.textSecondary,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isStudent
                        ? const [
                            BoxShadow(
                              color: Color(0x33155DFC),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                                isStudent
                                    ? 'Create my account'
                                    : 'Create my account (limited access)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                        if (!isStudent) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ──
              const DividerWithText(label: 'or continue with'),
              const SizedBox(height: 24),

              // ── Social Buttons ──
              Row(
                children: [
                  Expanded(
                    child: SocialButton(
                      label: 'Google',
                      icon: Icons.g_mobiledata,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SocialButton(
                      label: 'Github',
                      icon: Icons.code,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Footer ──
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: c.textSecondary,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    children: [
                      TextSpan(
                        text: 'Sign in',
                        style: TextStyle(
                          color: c.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          fontFamily: 'Inter',
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/signup',
                            (route) => false,
                          ),
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
            style: const TextStyle(
              color: AppColors.red,
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
