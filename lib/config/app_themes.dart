import 'package:flutter/material.dart';

class AppTheme {
  // Color constants
  static const Color primaryColor = Color(0xFF2E3A59);
  static const Color backgroundColor = Color(0xFF2E3A59);
  static const Color accentColor = Color(0xFFD29A67);
  static const Color textColor = Color(0xFF2E3A59);
  static const Color appBarTextColor = Colors.white;
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      textTheme: TextTheme(
        headlineLarge: TextStyle(
          color: accentColor,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: TextStyle(color: textColor),
        bodyMedium: TextStyle(color: textColor),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: accentColor,
        textTheme: ButtonTextTheme.primary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: appBarTextColor),
        titleTextStyle: const TextStyle(
          color: appBarTextColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
      ),
    );
  }
}
