import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPillCheckbox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;
  final Color selectedColor;
  final Color unselectedColor;
  final Color checkColor;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  const CustomPillCheckbox({
    Key? key,
    required this.text,
    required this.isSelected,
    this.onChanged,
    this.selectedColor = const Color(0xFF2E3A59),
    this.unselectedColor = const Color(0xFFD4A373),
    this.checkColor = const Color(0xFF2E3A59),
    this.borderRadius = 12.0,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!isSelected) : null,
      child: Container(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? selectedColor : unselectedColor.withOpacity(0.5),
            width: isSelected ? 1.2 : 0.8,
          ),
          color: isSelected ? unselectedColor.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: textStyle ??
                  GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? selectedColor : unselectedColor,
                  width: 1.0,
                ),
                color: Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: checkColor,
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
