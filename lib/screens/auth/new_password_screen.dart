import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController    = TextEditingController();
  final _confirmController     = TextEditingController();
  bool _isLoading              = false;
  bool _success                = false;

  // pulled from route arguments
  late String _oobCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _oobCode = (args?['oobCode'] as String?) ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Validation ──
  bool _isStrongPassword(String p) {
    if (p.length < 8)                                          return false;
    if (!RegExp(r'[A-Z]').hasMatch(p))                        return false;
    if (!RegExp(r'[0-9]').hasMatch(p))                        return false;
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(p))     return false;
    return true;
  }

  Future<void> _handleConfirm() async {
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (!_isStrongPassword(password)) {
      _showError(
        'Password must be 8+ characters with uppercase, number & special character.',
      );
      return;
    }
    if (password != confirm) {
      _showError('Passwords do not match.');
      return;
    }
    if (_oobCode.isEmpty) {
      _showError('Invalid or expired reset link. Please request a new one.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.confirmPasswordReset(
        code:        _oobCode,
        newPassword: password,
      );
      if (mounted) setState(() => _success = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _showError(e.message ?? 'Something went wrong. Please try again.');
      }
    } catch (e) {
      if (mounted) _showError('An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: AppColors.red,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ───────────────────────────── UI ─────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _success ? _buildSuccess(c) : _buildForm(c),
        ),
      ),
    );
  }

  // ── Form state ──
  Widget _buildForm(dynamic c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Title
        Center(
          child: Text(
            'Set New Password',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 26,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Your new password must be different\nfrom previously used passwords.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 15,
              fontFamily: 'Inter',
            ),
          ),
        ),
        const SizedBox(height: 36),

        // New password field
        AuthTextField(
          hint: 'New Password',
          icon: Icons.lock_outline,
          obscure: true,
          showStrengthIndicator: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 16),

        // Confirm password field
        AuthTextField(
          hint: 'Confirm Password',
          icon: Icons.lock_outline,
          obscure: true,
          hideStrength: true,
          controller: _confirmController,
          validator: (v) {
            if (v == null || v.isEmpty) return 'Please confirm your password';
            if (v != _passwordController.text) return 'Passwords do not match';
            return null;
          },
        ),
        const SizedBox(height: 28),

        // Confirm button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Reset Password',
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

        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/signup', (r) => false,
            ),
            icon: Icon(Icons.arrow_back_rounded, size: 16, color: c.primary),
            label: Text(
              'Back to Sign In',
              style: TextStyle(
                color: c.primary,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Success state ──
  Widget _buildSuccess(dynamic c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 48,
            color: AppColors.green,
          ),
        ),
        const SizedBox(height: 28),

        Text(
          'Password Reset!',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 26,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Your password has been successfully reset.\nYou can now sign in with your new password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 36),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/signup', (r) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: const Text(
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
      ],
    );
  }
}
