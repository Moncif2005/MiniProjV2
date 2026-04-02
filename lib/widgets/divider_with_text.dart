import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class DividerWithText extends StatelessWidget {
  final String? label;
  final String? text;

  const DividerWithText({super.key, this.label, this.text});

  String get _content => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Expanded(
          child: Divider(color: c.border, thickness: 1.24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            _content,
            style: TextStyle(
              color: c.textSecondary,
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: c.border, thickness: 1.24),
        ),
      ],
    );
  }
}