import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../widgets/social_button.dart';
import '../../widgets/divider_with_text.dart';

// Class is named SignUpScreen to match the '/signup' route and auth_wrapper reference
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController    = TextEditingController();
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
    final password   = _passwordController.text;
    if (!emailRegex.hasMatch(_emailController.text)) return false;
    if (password.length < 8)                          return false;
    if (!RegExp(r'[A-Z]').hasMatch(password))         return false;
    if (!RegExp(r'[0-9]').hasMatch(password))         return false;
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(password)) return false;
    return true;
  }

Future<void> _handleSignIn() async {
  if (!_validateAll()) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Please fix the errors before continuing.'),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
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
      // ✅ نجاح! لا تضع أي Navigator هنا.
      // فقط اعرض رسالة، وسيقوم AuthWrapper بالباقي.
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Welcome back! 🎉'),
        backgroundColor: AppColors.green,
        behavior: SnackBarBehavior.floating,
      ));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sign in failed. Please check your credentials.'),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred: $e'),
        backgroundColor: AppColors.red,
      ));
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
                  width: 210,
                  height: 64,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox(height: 64),
                ),
              ),
              const SizedBox(height: 16),

              Center(child: Text('Welcome Back',
                  style: TextStyle(color: c.textPrimary, fontSize: 24,
                      fontFamily: 'Inter', fontWeight: FontWeight.w700))),
              const SizedBox(height: 8),
              Center(child: Text('Formanova & Work Platform',
                  style: TextStyle(color: c.textSecondary, fontSize: 16,
                      fontFamily: 'Inter'))),
              const SizedBox(height: 32),

              AuthTextField(
                hint: 'Email Address',
                icon: Icons.email_outlined,
                controller: _emailController,
              ),
              const SizedBox(height: 16),

              AuthTextField(
                hint: 'Password',
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
                  child: Text('Forgot password?',
                      style: TextStyle(color: c.primary, fontFamily: 'Inter',
                          fontWeight: FontWeight.w700)),
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
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    shadowColor: AppColors.primaryLight,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In',
                          style: TextStyle(color: Colors.white, fontSize: 16,
                              fontFamily: 'Inter', fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 24),

              const DividerWithText(label: 'Or continue with'),
              const SizedBox(height: 16),

              SocialButton(
                label: 'Google',
                icon: Icons.g_mobiledata,
                onTap: () {},
              ),
              const SizedBox(height: 24),

              Center(
                child: Text.rich(TextSpan(children: [
                  TextSpan(
                    text: 'New to Formanova? ',
                    style: TextStyle(color: c.textSecondary, fontSize: 16,
                        fontFamily: 'Inter'),
                  ),
                  TextSpan(
                    text: 'Create Account',
                    style: TextStyle(color: c.primary, fontSize: 16,
                        fontFamily: 'Inter', fontWeight: FontWeight.w700),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () =>
                          Navigator.pushNamed(context, '/create-account'),
                  ),
                ]), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
