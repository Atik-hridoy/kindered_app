import 'package:flutter/material.dart';

class CustomToggleButton extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final double toggleSize;
  final Duration animationDuration;

  const CustomToggleButton({
    super.key,
    required this.isActive,
    required this.onChanged,
    this.width = 52.0,
    this.height = 32.0,
    this.toggleSize = 24.0,
    this.activeColor = const Color(0xFFD89A58),
    this.inactiveColor = const Color(0xFFB0AEAC),
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: AnimatedContainer(
        duration: animationDuration,
        width: width,
        height: height,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? activeColor : inactiveColor,
        ),
        child: AnimatedAlign(
          duration: animationDuration,
          alignment: isActive ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: toggleSize,
            height: toggleSize,
            decoration: BoxDecoration(
              color: const Color(0xFF2E3A59),
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
