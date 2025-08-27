import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomCheckboxMulty extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsets padding;
  final double height;
  final double titleFontSize;
  final double descriptionFontSize;

  const CustomCheckboxMulty({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.selectedColor = const Color(0xFF2E3A59),
    this.unselectedColor = Colors.transparent,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.height = 60.0,
    this.titleFontSize = 16.0, // Default font size for title
    this.descriptionFontSize = 14.0, // Default font size for description
  });

  @override
  Widget build(BuildContext context) {
    final title = label.split('\n')[0];
    final description = label.split('\n').length > 1 ? label.split('\n')[1] : "";
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(
          minHeight: height,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: isSelected ? selectedColor : const Color(0xFFD29A67).withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.playfairDisplay(
                        color: isSelected ? Colors.white : textColor,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.inter(
                          color: isSelected 
                              ? const Color(0xFF2C3E50).withValues(alpha: 0.6) 
                              : Colors.white.withValues(alpha: 0.8),
                          fontSize: descriptionFontSize,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF2C3E50) : const Color(0xFFD29A67).withValues(alpha: 0.6),
                    width: isSelected ? 6 : 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
