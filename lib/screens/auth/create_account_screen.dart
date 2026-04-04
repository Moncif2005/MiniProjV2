import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
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
  int _selectedProfile = 0; // 0=étudiant 1=enseignant 2=recruteur

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
    final passOk = _isValidPassword(_passwordController.text);
    final confirmOk = _confirmController.text.isNotEmpty && _passwordsMatch();

    setState(() {
      _nameError = !nameOk;
      _emailError = !emailOk;
      _passwordError = !passOk;
      _confirmError = !confirmOk;
      _confirmMismatch =
          _confirmController.text.isNotEmpty && !_passwordsMatch();
    });
    return nameOk && emailOk && passOk && confirmOk;
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

    setState(() => _isLoading = true);

    try {
      // Use the provider instance (not a new AuthService())
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // ── Firebase sign up ──
      final roleMap = ['etudiant', 'enseignant', 'recruteur'];
      final selectedRole = roleMap[_selectedProfile];

      final ok = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
        role: selectedRole,
      );
      if (!ok) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign up failed. Please check your information.'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      // ── Save name + email + role locally ──
      final roles = [
        UserRole.etudiant,
        UserRole.enseignant,
        UserRole.recruteur,
      ];
      userProvider.setUserWithRole(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: roles[_selectedProfile],
      );

      // ── Navigate to role-specific home ──
      if (!mounted) return;
      if (ok && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false);
      }
      // if (!mounted) return;
      // const routes = ['/etudiant/home', '/enseignant/home', '/recruteur/home'];
      // Navigator.pushNamedAndRemoveUntil(
      //   context,
      //   routes[_selectedProfile],
      //   (r) => false,
      // );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.red),
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
                'Join Formanova today and start your learning journey!',
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 32),

              // ── Role selector ──
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

              // ── Fields ──
              AuthTextField(
                hint: 'Full name',
                icon: Icons.person_outline_rounded,
                controller: _nameController,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Full name is required'
                    : null,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                hint: 'Email Address',
                icon: Icons.mail_outline_rounded,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                hint: 'Password',
                icon: Icons.lock_outline_rounded,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                hint: 'Confirm Password',
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

              // Listens to confirm field changes
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
                    color: [
                      AppColors.primary,
                      AppColors.green,
                      AppColors.purple,
                    ][_selectedProfile],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33155DFC),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create my account',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const DividerWithText(label: 'or continue with'),
              const SizedBox(height: 24),

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
                            (r) => false,
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
