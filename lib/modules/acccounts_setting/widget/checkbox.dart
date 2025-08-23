import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckbox extends StatelessWidget {
 final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double height;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = const Color(0xFFD4A574),
    this.unselectedColor = Colors.transparent,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.height = 60.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFD29A67).withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.playfairDisplay(
                  color: isSelected ? const Color(0xFF2C3E50) : textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFFD29A67).withValues(alpha: 0.6),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: isSelected
                    ? Container(
                        width: 16,
                        height: 16,                        decoration:BoxDecoration(
                          color: Color(0xFF2C3E50),
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}