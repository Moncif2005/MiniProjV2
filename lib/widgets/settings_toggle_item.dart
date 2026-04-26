import 'package:flutter/material.dart';

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

  // Keep in sync when the parent rebuilds with a new initialValue
  // (e.g. ThemeProvider notifies and isDark flips)
  @override
  void didUpdateWidget(SettingsToggleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _value = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _value = !_value);
        widget.onChanged?.call(_value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 26,
        padding: EdgeInsets.only(
          left: _value ? 20 : 3,
          right: _value ? 3 : 20,
          top: 3,
          bottom: 3,
        ),
        decoration: BoxDecoration(
          color: _value
              ? const Color(0xFF155DFC)
              : const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x19000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
