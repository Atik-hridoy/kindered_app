import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_themes.dart';
import 'package:get/get.dart';
import '../../config/app_routes.dart';

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
                // Logo with exact dimensions
                SizedBox(
                  width: 206,
                  height: 40,
                  child: SvgPicture.asset(
                    'assets/svg/Kindred.svg',
                    width: 206,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}