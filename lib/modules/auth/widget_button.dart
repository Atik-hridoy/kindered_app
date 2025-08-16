import 'package:flutter/material.dart';

enum AuthButtonStyle { filled, outline }

class AuthCtaButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final AuthButtonStyle style;

  const AuthCtaButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.style = AuthButtonStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    if (style == AuthButtonStyle.outline) {
      // White outline button: "I have an account"
      return SizedBox(
        width: 335,
        height: 48,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.white, width: 1.2),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            backgroundColor: Colors.white,
            // surfaceTintColor: Colors.transparent,
            foregroundColor: const Color(0xFF2E3A59), // Dark blue text
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(text),
        ),
      );
    }

    // Filled gradient button: "Create an account"
    return SizedBox(
      width: 335,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFD89A58), // top
              Color(0xFFB27438), // bottom
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            foregroundColor: const Color(0xFF2E3A59), // Dark blue text
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}