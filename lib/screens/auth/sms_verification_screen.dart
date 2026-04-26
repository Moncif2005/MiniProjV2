import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_colors.dart';

/// Full SMS verification flow:
///  1. Enter phone number → send OTP
///  2. Enter 6-digit OTP  → link phone to account
///
/// Usage:
///   Navigator.push(context, MaterialPageRoute(
///     builder: (_) => const SmsVerificationScreen(),
///   ));
class SmsVerificationScreen extends StatefulWidget {
  const SmsVerificationScreen({super.key});

  @override
  State<SmsVerificationScreen> createState() =>
      _SmsVerificationScreenState();
}

class _SmsVerificationScreenState extends State<SmsVerificationScreen> {
  // ── Step 0 = phone entry, Step 1 = OTP entry ──
  int _step = 0;

  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());

  bool _loading = false;
  String? _verificationId;
  int? _resendToken;
  String _errorText = '';

  @override
  void dispose() {
    _phoneController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // ── Send OTP ──────────────────────────────────────────────────────────────
  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _errorText = 'Please enter a phone number.');
      return;
    }
    // Simple E.164 check
    if (!RegExp(r'^\+[1-9]\d{6,14}$').hasMatch(phone)) {
      setState(() =>
          _errorText = 'Use E.164 format, e.g. +213xxxxxxxxx');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = '';
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      forceResendingToken: _resendToken,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieval / instant verification (Android only)
        await _linkCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (mounted) {
          setState(() {
            _loading = false;
            _errorText = e.message ?? 'Verification failed.';
          });
        }
      },
      codeSent: (String verificationId, int? resendToken) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _loading = false;
            _step = 1;
          });
        }
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<void> _verifyOtp() async {
    final code = _otpControllers.map((c) => c.text).join();
    if (code.length != 6) {
      setState(() => _errorText = 'Please enter the 6-digit code.');
      return;
    }
    if (_verificationId == null) {
      setState(() => _errorText = 'Session expired. Please resend the code.');
      return;
    }

    setState(() {
      _loading = true;
      _errorText = '';
    });

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );

    await _linkCredential(credential);
  }

  // ── Link credential to current user ──────────────────────────────────────
  Future<void> _linkCredential(PhoneAuthCredential credential) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in.');

      // If phone is already linked, update; otherwise link fresh
      final linked = user.providerData
          .any((p) => p.providerId == PhoneAuthProvider.PROVIDER_ID);

      if (linked) {
        await user.updatePhoneNumber(credential);
      } else {
        await user.linkWithCredential(credential);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.green,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Phone number verified via SMS!',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
        Navigator.of(context).pop(true); // return success
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = e.message ?? 'Failed to verify code.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorText = e.toString();
        });
      }
    }
  }

  // ── OTP box ───────────────────────────────────────────────────────────────
  Widget _buildOtpBox(int index) {
    final c = context.colors;
    return SizedBox(
      width: 44,
      height: 54,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: c.textPrimary,
          fontSize: 22,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: c.surface,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: c.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _otpFocusNodes[index - 1].requestFocus();
          }
          // Auto-submit when last digit typed
          if (index == 5 && v.isNotEmpty) {
            _verifyOtp();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.surface,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_step == 1) {
                        setState(() {
                          _step = 0;
                          _errorText = '';
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: ShapeDecoration(
                        color: c.surface,
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(width: 1.24, color: c.border),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x19000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 16,
                        color: c.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'SMS Verification',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 24),
                child: _step == 0
                    ? _buildPhoneStep(c)
                    : _buildOtpStep(c),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 0: phone entry ───────────────────────────────────────────────────
  Widget _buildPhoneStep(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.phone_outlined,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Add your phone number',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 24,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll send you a 6-digit verification code via SMS.',
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 32),

        // Phone field
        Text(
          'Phone Number',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            color: c.surface,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  width: 1.5,
                  color: _errorText.isNotEmpty
                      ? AppColors.red
                      : c.border),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Inter',
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: '+213 6xx xxx xxx',
              hintStyle: TextStyle(
                  color: c.textMuted, fontFamily: 'Inter'),
              prefixIcon: Icon(Icons.phone_outlined,
                  color: c.textMuted, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
          ),
        ),

        if (_errorText.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.red, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _errorText,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),
        Text(
          'Include country code, e.g. +213 for Algeria.',
          style: TextStyle(
            color: c.textMuted,
            fontSize: 12,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 36),

        // Send OTP button
        GestureDetector(
          onTap: _loading ? null : _sendOtp,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
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
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Send Verification Code',
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
      ],
    );
  }

  // ── Step 1: OTP entry ─────────────────────────────────────────────────────
  Widget _buildOtpStep(dynamic c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.greenLight.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.sms_outlined,
            color: AppColors.green,
            size: 32,
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Enter the code',
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 24,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A 6-digit code was sent to ${_phoneController.text.trim()}',
          style: TextStyle(
            color: c.textSecondary,
            fontSize: 15,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 36),

        // OTP boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, _buildOtpBox),
        ),

        if (_errorText.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: AppColors.red, size: 14),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _errorText,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 36),

        // Verify button
        GestureDetector(
          onTap: _loading ? null : _verifyOtp,
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3300A63E),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text(
                      'Verify Code',
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
        const SizedBox(height: 20),

        // Resend
        Center(
          child: GestureDetector(
            onTap: _loading
                ? null
                : () {
                    setState(() {
                      _step = 0;
                      _errorText = '';
                      for (final c in _otpControllers) {
                        c.clear();
                      }
                    });
                  },
            child: Text(
              'Didn\'t receive a code? Change number',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
