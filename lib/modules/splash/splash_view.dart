import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/config/app_themes.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/auth/service/login.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    
    // Auto-login functionality
    Timer(const Duration(seconds: 2), () async {
      await _checkAuthAndNavigate();
    });
  }

  /// Check authentication status and navigate accordingly
  Future<void> _checkAuthAndNavigate() async {
    try {
      AppLogger.info('🔍 [SPLASH] Checking authentication status...');
      
      // Check if user has valid authentication data
      final hasValidAuth = LocalStorage.isAuthenticated();
      final savedEmail = LocalStorage.myEmail;
      final savedToken = LocalStorage.token;
      
      AppLogger.info('📋 [SPLASH] Auth check results:');
      AppLogger.info('   - Has valid auth: $hasValidAuth');
      AppLogger.info('   - Saved email: ${savedEmail.isNotEmpty ? savedEmail : "None"}');
      AppLogger.info('   - Saved token: ${savedToken.isNotEmpty ? "${savedToken.substring(0, 10)}..." : "None"}');
      
      if (hasValidAuth && savedEmail.isNotEmpty && savedToken.isNotEmpty) {
        // User has saved authentication data, try auto-login
        AppLogger.info('🚀 [SPLASH] Attempting auto-login for: $savedEmail');
        
        try {
          // First validate the saved token
          final authService = AuthService();
          final tokenValidationResult = await authService.validateTokenWithLogin(savedEmail, savedToken);
          
          AppLogger.info('📝 [SPLASH] Token validation result: $tokenValidationResult');
          
          if (tokenValidationResult['success'] == true) {
            // Token is still valid, navigate directly to home
            AppLogger.success('✅ [SPLASH] Auto-login successful! Navigating to home...');
            Get.offAllNamed(AppRoutes.locationView);
            return;
          } else if (tokenValidationResult['needsRefresh'] == true) {
            // Token is expired, try to get a new one with login
            AppLogger.info('🔄 [SPLASH] Token expired, attempting to refresh...');
            final loginResult = await authService.login(savedEmail);
            
            if (loginResult['success'] == true) {
              // Login successful but needs OTP
              AppLogger.info('📱 [SPLASH] Login successful, needs OTP verification');
              Get.offAllNamed(
                AppRoutes.otp,
                arguments: {
                  'target': savedEmail,
                  'type': 'email',
                  'source': 'login'
                }
              );
              return;
            }
          } else if (tokenValidationResult['error']?.contains('not verified') == true || 
                     tokenValidationResult['error']?.contains('User not verified') == true) {
            // User exists but needs OTP verification
            AppLogger.info('📱 [SPLASH] User needs OTP verification, navigating to OTP...');
            Get.offAllNamed(
              AppRoutes.otp,
              arguments: {
                'target': savedEmail,
                'type': 'email',
                'source': 'login'
              }
            );
            return;
          } else {
            // Token is invalid or user doesn't exist
            AppLogger.warning('⚠️ [SPLASH] Invalid auth data, clearing and proceeding to onboarding...');
            await LocalStorage.clearAll();
          }
        } catch (e) {
          AppLogger.error('❌ [SPLASH] Auto-login validation failed: $e');
          // Clear invalid auth data
          await LocalStorage.clearAll();
        }
      } else {
        AppLogger.info('📝 [SPLASH] No valid auth data found, proceeding to onboarding...');
      }
      
      // No valid authentication or auto-login failed, proceed to onboarding
      Get.offAllNamed(AppRoutes.onboarding);
      
    } catch (e) {
      AppLogger.error('❌ [SPLASH] Error during auth check: $e');
      // Fallback to onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    }
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