import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  // ── Shared ──
  final String hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  // ── Old API — used by signup_screen ──
  final IconData? icon;
  final bool obscure;
  final bool hideStrength; // ← NEW: suppresses strength indicator

  // ── New API — used by create_account_screen ──
  final String? label;
  final IconData? prefixIcon;
  final bool hasError;
  final String errorMessage;
  final bool isPassword;
  final bool showStrengthIndicator;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
    super.key,
    required this.hint,
    this.icon,
    this.obscure = false,
    this.hideStrength = false, // ← default false
    this.label,
    this.prefixIcon,
    this.hasError = false,
    this.errorMessage = '',
    this.isPassword = false,
    this.showStrengthIndicator = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.controller,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscure;
  String? _internalError;
  late TextEditingController _controller;

  IconData? get _prefixIcon    => widget.prefixIcon ?? widget.icon;
  bool get _isPasswordField    => widget.isPassword || widget.obscure;
  bool get _showError          => widget.hasError || _internalError != null;
  String get _displayError     => widget.hasError
      ? widget.errorMessage
      : (_internalError ?? '');

  // ── Only show strength when explicitly requested
  //    AND not suppressed by hideStrength ──
  bool get _showStrength =>
      _isPasswordField &&
      !widget.hideStrength &&
      (widget.showStrengthIndicator || widget.obscure) &&
      _controller.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _isObscure  = _isPasswordField;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  // ── Old-API built-in validators ──
  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w.-]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
      return 'Enter a valid email (e.g. name@gmail.com)';
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Password is required';
    }
    if (v.length < 8) {
      return 'At least 8 characters required';
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return 'At least one uppercase letter required';
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return 'At least one number required';
    }
    if (!RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(v)) {
      return 'At least one special character required';
    }
    return null;
  }

  String? _runOldValidator(String? v) {
    if (widget.validator != null) {
      return widget.validator!(v);
    }
    if (widget.hint.toLowerCase().contains('email')) {
      return _validateEmail(v);
    }
    if (widget.hint.toLowerCase().contains('password')) {
      return _validatePassword(v);
    }
    if (v == null || v.trim().isEmpty) {
      return '${widget.hint} is required';
    }
    return null;
  }

  // ── Strength checks ──
  bool get _hasLength => _controller.text.length >= 8;
  bool get _hasUpper  => RegExp(r'[A-Z]').hasMatch(_controller.text);
  bool get _hasNumber => RegExp(r'[0-9]').hasMatch(_controller.text);
  bool get _hasSymbol =>
      RegExp(r'[!@#\$&*~%^()_\-+=<>?/]').hasMatch(_controller.text);

  @override
  Widget build(BuildContext context) {
    final c           = context.colors;
    final borderColor = _showError ? AppColors.red : c.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // ── Label (new API only) ──
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ── Input Box ──
        Container(
          decoration: ShapeDecoration(
            color: c.inputBg,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 1.24, color: borderColor),
              borderRadius: BorderRadius.circular(16),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 2,
                offset: Offset(0, 1),
                spreadRadius: -1,
              ),
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            obscureText: _isObscure,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 16,
              fontFamily: 'Inter',
            ),
            onChanged: (val) {
              setState(() {
                if (widget.label == null) {
                  _internalError = _runOldValidator(val);
                }
              });
              widget.onChanged?.call(val);
            },
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: c.textMuted,
                fontSize: 16,
                fontFamily: 'Inter',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 18),
              prefixIcon: _prefixIcon != null
                  ? Icon(
                      _prefixIcon,
                      size: 20,
                      color: _showError
                          ? AppColors.red
                          : c.textSecondary,
                    )
                  : null,
              suffixIcon: _isPasswordField
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => _isObscure = !_isObscure),
                      child: Icon(
                        _isObscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: c.textSecondary,
                      ),
                    )
                  : null,
            ),
          ),
        ),

        // ── Error Message ──
        if (_showError && _displayError.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.red,
                size: 14,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  _displayError,
                  style: const TextStyle(
                    color: AppColors.red,
                    fontSize: 12,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ],

        // ── Password Strength Indicator ──
        if (_showStrength) ...[
          const SizedBox(height: 10),
          _StrengthRow(
              label: 'Minimum 8 caractères / 8+ characters',
              ok: _hasLength),
          const SizedBox(height: 4),
          _StrengthRow(
              label: '1 lettre majuscule / Uppercase letter',
              ok: _hasUpper),
          const SizedBox(height: 4),
          _StrengthRow(
              label: '1 chiffre / Number',
              ok: _hasNumber),
          const SizedBox(height: 4),
          _StrengthRow(
              label: '1 caractère spécial / Special character',
              ok: _hasSymbol),
        ],
      ],
    );
  }
}

class _StrengthRow extends StatelessWidget {
  final String label;
  final bool ok;

  const _StrengthRow({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    final color = ok ? AppColors.green : AppColors.lightTextMuted;
    return Row(
      children: [
        Icon(
          ok
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: color,
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