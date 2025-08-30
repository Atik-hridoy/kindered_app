import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/config/app_themes.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Simple splash -> onboarding navigation
    Timer(const Duration(seconds: 2), () {
      Get.offAllNamed(AppRoutes.onboarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive dimensions
    final logoWidth = screenWidth * 0.55; // 55% of screen width
    final logoHeight = logoWidth * (40/206); // Maintain aspect ratio
    final topPadding = screenHeight * 0.1; // 10% from top

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.primaryColor,
      body: Stack(
        children: [
          // Background color
          Container(color: AppTheme.lightTheme.primaryColor),
          
          // Centered content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with responsive dimensions
                SizedBox(
                  width: logoWidth,
                  height: logoHeight,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SvgPicture.asset(
                      'assets/svg/Kindred.svg',
                      width: 206, // Original design width
                      height: 40,  // Original design height
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03), // 3% of screen height
              ],
            ),
          ),
        ],
      ),
    );
  }
}