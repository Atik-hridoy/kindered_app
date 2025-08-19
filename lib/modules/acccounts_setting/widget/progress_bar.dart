import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget implements PreferredSizeWidget {
  final double value;
  final Color color;
  final Color backgroundColor;
  final double height;
  @override
  final Size preferredSize = const Size.fromHeight(6.0);

  const CustomProgressBar({
    super.key,
    required this.value,
    this.color = const Color(0xFFD4A373),
    this.backgroundColor = const Color(0xFF686766),
    this.height = 6.0,
  }) : assert(value >= 0.0 && value <= 1.0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.5),
      child: LinearProgressIndicator(
        value: value,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        minHeight: height,
      ),
    );
  }
}