import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:minipr/providers/user_provider.dart';
import 'package:minipr/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/divider_with_text.dart';

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
    if (!emailRegex.hasMatch(_emailController.text)) {
      return false;
    }
    if (password.length < 8) {
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return false;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return false;
    }
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(password)) {
      return false;
    }
    return true;
  }

  Future<void> _handleSignIn() async {
    if (!_validateAll()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before continuing.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final response = await authService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (response) {
        final user = authService.userProfile;
        print(user.toString());
        // if (user != null) {
        //   userProvider.setUser(
        //     name: user['name'] ?? '',
        //     email: user['email'] ?? '',
        //   );
        // }
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in failed. Please check your credentials.'),
              backgroundColor: AppColors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
          ),
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
                child: Image.network(
                  'https://placehold.co/210x64',
                  width: 210,
                  height: 64,
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 16),

              // ── Title ──
              Center(
                child: Text(
                  'Welcome Back',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 24,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Subtitle ──
              Center(
                child: Text(
                  'Formanova & Work Platform',
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Email ──
              AuthTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              // ── Password — strength indicator hidden ──
              AuthTextField(
                hint: 'Password',
                icon: Icons.lock_outline,
                obscure: true,
                hideStrength: true, // ← hides the checklist
                controller: _passwordController,
              ),
              const SizedBox(height: 8),

              // ── Forgot Password ──
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: c.primary,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Sign In Button ──
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
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Divider ──
              const DividerWithText(label: 'Or continue with'),
              const SizedBox(height: 16),

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

              // ── Footer ──
              Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'New to Formanova? ',
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 16,
                          fontFamily: 'Inter',
                        ),
                      ),
                      TextSpan(
                        text: 'Create Account',
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
