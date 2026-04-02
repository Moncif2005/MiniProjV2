import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SettingsToggleItem extends StatefulWidget {
  final String title;
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const SettingsToggleItem({
    super.key,
    required this.title,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<SettingsToggleItem> createState() => _SettingsToggleItemState();
}

class _SettingsToggleItemState extends State<SettingsToggleItem> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      onChanged: (v) {
        setState(() => _value = v);
        widget.onChanged?.call(v);
      },
      activeColor: AppColors.primary,
      activeTrackColor: AppColors.primaryLight,
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE5E5E5),
    );
  }
}
