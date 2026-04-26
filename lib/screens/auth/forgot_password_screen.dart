import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String v) =>
      RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context).enterValidEmail),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() => _emailSent = true);
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.message ?? AppLocalizations.of(context).error),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${AppLocalizations.of(context).error}: $e'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = AppLocalizations.of(context);

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
          child: _emailSent ? _buildSuccessState(c, l) : _buildFormState(c, l),
        ),
      ),
    );
  }

  Widget _buildFormState(dynamic c, AppLocalizations l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded, size: 40, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Text(
            AppLocalizations.of(context).forgotPasswordTitle,
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
            AppLocalizations.of(context).forgotPasswordSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 15, fontFamily: 'Inter'),
          ),
        ),
        const SizedBox(height: 36),
        AuthTextField(
          hint: AppLocalizations.of(context).emailAddress,
          icon: Icons.email_outlined,
          controller: _emailController,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    AppLocalizations.of(context).sendResetLink,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, size: 16, color: c.primary),
            label: Text(
              AppLocalizations.of(context).backToSignIn,
              style: TextStyle(color: c.primary, fontFamily: 'Inter', fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(dynamic c, AppLocalizations l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.mark_email_read_rounded, size: 46, color: AppColors.green),
        ),
        const SizedBox(height: 28),
        Text(
          AppLocalizations.of(context).checkInbox,
          style: TextStyle(color: c.textPrimary, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          '${AppLocalizations.of(context).resetLinkSent}\n${_emailController.text.trim()}',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 15, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).checkSpam,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: Text(
              AppLocalizations.of(context).backToSignIn,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _isLoading ? null : _handleResetPassword,
          child: Text(
            AppLocalizations.of(context).resendEmail,
            style: TextStyle(color: c.primary, fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
