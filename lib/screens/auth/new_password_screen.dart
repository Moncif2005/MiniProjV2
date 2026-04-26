import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_text_field.dart';
import '../../l10n/app_localizations.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController  = TextEditingController();
  bool _isLoading           = false;
  bool _success             = false;
  late String _oobCode;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _oobCode = (args?['oobCode'] as String?) ?? '';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String p) {
    if (p.length < 8) return false;
    if (!RegExp(r'[A-Z]').hasMatch(p)) return false;
    if (!RegExp(r'[0-9]').hasMatch(p)) return false;
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(p)) return false;
    return true;
  }

  Future<void> _handleConfirm() async {
    final password = _passwordController.text;
    final confirm  = _confirmController.text;

    if (!_isStrongPassword(password)) {
      _showError(AppLocalizations.of(context).passwordStrengthHint);
      return;
    }
    if (password != confirm) {
      _showError(AppLocalizations.of(context).passwordsNotMatch);
      return;
    }
    if (_oobCode.isEmpty) {
      _showError(AppLocalizations.of(context).invalidResetLink);
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
      if (mounted) _showError(e.message ?? AppLocalizations.of(context).error);
    } catch (e) {
      if (mounted) _showError('${AppLocalizations.of(context).error}: $e');
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
          child: _success ? _buildSuccess(c, l) : _buildForm(c, l),
        ),
      ),
    );
  }

  Widget _buildForm(dynamic c, AppLocalizations l) {
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
            AppLocalizations.of(context).setNewPassword,
            style: TextStyle(
              color: c.textPrimary, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            AppLocalizations.of(context).newPasswordSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textSecondary, fontSize: 15, fontFamily: 'Inter'),
          ),
        ),
        const SizedBox(height: 36),
        AuthTextField(
          hint: AppLocalizations.of(context).newPassword,
          icon: Icons.lock_outline,
          obscure: true,
          showStrengthIndicator: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          hint: AppLocalizations.of(context).confirmNewPassword,
          icon: Icons.lock_outline,
          obscure: true,
          hideStrength: true,
          controller: _confirmController,
          validator: (v) {
            if (v == null || v.isEmpty) return AppLocalizations.of(context).confirmPassword;
            if (v != _passwordController.text) return AppLocalizations.of(context).passwordsNotMatch;
            return null;
          },
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    AppLocalizations.of(context).updatePassword,
                    style: const TextStyle(
                      color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/signup', (r) => false),
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

  Widget _buildSuccess(dynamic c, AppLocalizations l) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(color: AppColors.green.withOpacity(0.12), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, size: 48, color: AppColors.green),
        ),
        const SizedBox(height: 28),
        Text(
          AppLocalizations.of(context).passwordUpdated,
          style: TextStyle(color: c.textPrimary, fontSize: 26, fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context).passwordUpdatedSubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.textSecondary, fontSize: 15, fontFamily: 'Inter'),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/signup', (r) => false),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              shadowColor: AppColors.primaryLight,
            ),
            child: Text(
              AppLocalizations.of(context).signIn,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter', fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
