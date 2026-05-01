import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../models/course_model.dart';
import '../../l10n/app_localizations.dart';

class PaymentScreen extends StatefulWidget {
  final CourseModel course;

  const PaymentScreen({super.key, required this.course});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  bool _isProcessing = false;
  bool _saveCard = false;

  final _cardNumberCtrl = TextEditingController();
  final _cardNameCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final AnimationController _successController;
  late final Animation<double> _successScale;
  late final Animation<double> _successFade;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardNameCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _successController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isProcessing = false;
      _showSuccess = true;
    });

    await _successController.forward();

    await Future.delayed(const Duration(milliseconds: 1800));

    if (mounted) {
      // Pop back to course details with a success flag
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    if (_showSuccess) {
      return _SuccessOverlay(
        courseName: widget.course.title,
        price: widget.course.certificatePrice,
        scaleAnim: _successScale,
        fadeAnim: _successFade,
        c: c,
      );
    }

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: c.iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: c.textPrimary, size: 18),
          ),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: c.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Order summary ──
            _OrderSummaryCard(course: widget.course, c: c),
            const SizedBox(height: 28),

            // ── Card form ──
            _CardForm(
              formKey: _formKey,
              cardNumberCtrl: _cardNumberCtrl,
              cardNameCtrl: _cardNameCtrl,
              expiryCtrl: _expiryCtrl,
              cvvCtrl: _cvvCtrl,
              saveCard: _saveCard,
              onSaveCardChanged: (v) => setState(() => _saveCard = v),
              c: c,
            ),

            const SizedBox(height: 32),

            // ── Secure badge ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 14, color: c.textMuted),
                const SizedBox(width: 6),
                Text(
                  'Secured by 256-bit SSL encryption',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: c.textMuted,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Pay button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Pay ${widget.course.certificatePrice} DZD',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Refund note ──
            Center(
              child: Text(
                '30-day money-back guarantee',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Order Summary Card ─────────────────────────────────────────────────────────
class _OrderSummaryCard extends StatelessWidget {
  final CourseModel course;
  final ThemeColors c;
  const _OrderSummaryCard({required this.course, required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Course image / icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: AppColors.gradientBlue,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: course.imageUrl != null && course.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(course.imageUrl!, fit: BoxFit.cover),
                      )
                    : const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: c.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.totalLessons} lessons · ${course.category}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: c.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _PriceLine(label: 'Course price', value: '${course.certificatePrice} DZD', c: c),
          const SizedBox(height: 8),
          _PriceLine(label: 'Platform fee', value: 'Free', isAccent: true, c: c),
          const SizedBox(height: 12),
          Container(height: 1, color: c.border),
          const SizedBox(height: 12),
          _PriceLine(
            label: 'Total',
            value: '${course.certificatePrice} DZD',
            isBold: true,
            c: c,
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final bool isAccent;
  final ThemeColors c;
  const _PriceLine({
    required this.label,
    required this.value,
    this.isBold = false,
    this.isAccent = false,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold ? c.textPrimary : c.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isAccent
                ? AppColors.green
                : (isBold ? AppColors.primary : c.textPrimary),
          ),
        ),
      ],
    );
  }
}

// ── Card Form ─────────────────────────────────────────────────────────────────
class _CardForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberCtrl;
  final TextEditingController cardNameCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final bool saveCard;
  final ValueChanged<bool> onSaveCardChanged;
  final ThemeColors c;

  const _CardForm({
    required this.formKey,
    required this.cardNumberCtrl,
    required this.cardNameCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.saveCard,
    required this.onSaveCardChanged,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Card Details',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 14),

          // Card number
          _PaymentField(
            controller: cardNumberCtrl,
            label: 'Card Number',
            hint: '1234 5678 9012 3456',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              _CardNumberFormatter(),
            ],
            validator: (v) {
              if (v == null || v.replaceAll(' ', '').length < 16) {
                return 'Enter a valid 16-digit card number';
              }
              return null;
            },
            c: c,
          ),
          const SizedBox(height: 14),

          // Card holder name
          _PaymentField(
            controller: cardNameCtrl,
            label: 'Cardholder Name',
            hint: 'John Doe',
            icon: Icons.person_outline_rounded,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Enter the cardholder name';
              return null;
            },
            c: c,
          ),
          const SizedBox(height: 14),

          // Expiry + CVV
          Row(
            children: [
              Expanded(
                child: _PaymentField(
                  controller: expiryCtrl,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  icon: Icons.calendar_today_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _ExpiryFormatter(),
                    LengthLimitingTextInputFormatter(5),
                  ],
                  validator: (v) {
                    if (v == null || v.length < 5) return 'Invalid expiry';
                    return null;
                  },
                  c: c,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _PaymentField(
                  controller: cvvCtrl,
                  label: 'CVV',
                  hint: '•••',
                  icon: Icons.lock_outline_rounded,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) {
                    if (v == null || v.length < 3) return 'Invalid CVV';
                    return null;
                  },
                  c: c,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Save card toggle
          GestureDetector(
            onTap: () => onSaveCardChanged(!saveCard),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: saveCard ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: saveCard ? AppColors.primary : c.border,
                      width: 1.5,
                    ),
                  ),
                  child: saveCard
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  'Save this card for future payments',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment Field ─────────────────────────────────────────────────────────────
class _PaymentField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ThemeColors c;

  const _PaymentField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.inputFormatters,
    this.validator,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: c.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          style: TextStyle(
            fontFamily: 'Inter',
            color: c.textPrimary,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textMuted, fontFamily: 'Inter'),
            prefixIcon: Icon(icon, color: c.textMuted, size: 20),
            filled: true,
            fillColor: c.inputBg,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: c.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.red, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.red, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ── Success Overlay ───────────────────────────────────────────────────────────
class _SuccessOverlay extends StatelessWidget {
  final String courseName;
  final num price;
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;
  final ThemeColors c;

  const _SuccessOverlay({
    required this.courseName,
    required this.price,
    required this.scaleAnim,
    required this.fadeAnim,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: c.bg,
      body: Center(
        child: FadeTransition(
          opacity: fadeAnim,
          child: ScaleTransition(
            scale: scaleAnim,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: AppColors.gradientGreen,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withOpacity(0.35),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: Colors.white, size: 52),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You now have full access to',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: c.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    courseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${price.toStringAsFixed(2)} DZD charged',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Text Input Formatters ─────────────────────────────────────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    if (text.length > 16) return oldValue;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final formatted = buffer.toString();
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    if (text.length > 4) return oldValue;
    String formatted = text;
    if (text.length >= 3) {
      formatted = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
