import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF2E3A59), // Updated to #2E3A59
      scaffoldBackgroundColor: const Color(0xFFF8F4E9), 
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          color: Color(0xFFD29A67), 
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
        // Add more text styles for better consistency
        bodyLarge: const TextStyle(color: Color(0xFF2E3A59)),
        bodyMedium: const TextStyle(color: Color(0xFF2E3A59)),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: Color(0xFFD29A67), 
        textTheme: ButtonTextTheme.primary, 
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2E3A59), // Using the same primary color
        iconTheme: IconThemeData(color: Color(0xFFF3F1E7)),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFD29A67), 
      ),
    );
  }
}
