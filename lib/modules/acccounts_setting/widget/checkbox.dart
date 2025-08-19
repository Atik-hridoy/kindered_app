import 'package:flutter/material.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final Color activeColor;
  final Color checkColor;
  final Color borderColor;
  final double size;
  final double borderWidth;
  final bool showLabel;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.activeColor = const Color(0xFFD4A373),
    this.checkColor = Colors.white,
    this.borderColor = const Color(0xFFD4A373),
    this.size = 24.0,
    this.borderWidth = 2.0,
    this.showLabel = true,
    this.padding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2634),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? activeColor : const Color(0xFF2D3A4A),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (showLabel) ...[
              Text(
                label,
                style: labelStyle ?? const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ] else const Spacer(),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: value ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(size / 2),
                border: Border.all(
                  color: value ? activeColor : borderColor.withValues(alpha: 0.5),
                  width: borderWidth,
                ),
              ),
              child: value
                  ? Icon(
                      Icons.check,
                      size: size * 0.7,
                      color: checkColor,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}