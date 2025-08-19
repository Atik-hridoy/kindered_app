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
    this.checkColor = const Color(0xFFD4A373),
    this.borderColor = const Color(0xFFD4A373),
    this.size = 24.0,
    this.borderWidth = 1.0,
    this.showLabel = true,
    this.padding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: value ? const Color(0xFFD4A373) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value ? const Color(0xFFD4A373) : const Color.fromARGB(255, 212, 154, 115).withValues(alpha: 0.8),
            width: borderWidth,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: labelStyle ?? const TextStyle(
                color: Color.fromARGB(255, 143, 65, 14),
                fontSize: 16,
                fontFamily: 'Playfair Display',
              ),
            ),
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                //color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(size / 2),
                border: Border.all(
                  color: const Color(0xFFD4A373).withValues(alpha: 0.8),
                  width: borderWidth,
                ),
              ),
              child: value
                  ? Center(
                      child: Container(
                        width: size * 1,
                        height: size * 1,
                        decoration: const BoxDecoration(
                          color: Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(
                            BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}