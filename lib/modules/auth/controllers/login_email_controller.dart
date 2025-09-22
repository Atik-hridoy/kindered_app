import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../service/login.dart';

class LoginEmailController extends GetxController {
  final AuthService _authService = AuthService();
  
  // Form controllers
  final emailController = TextEditingController();
  
  // Reactive variables
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  
  // Form key for validation
  final formKey = GlobalKey<FormState>();
  
  Future<void> login() async {
    if (emailController.text.trim().isEmpty) {
      errorMessage.value = 'Please enter your email';
      return;
    }
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      AppLogger.info('🔄 [LOGIN] Attempting login with email: ${emailController.text.trim()}');
      final result = await _authService.login(emailController.text.trim());
      
      AppLogger.info('📝 [LOGIN] Server response: $result');
      
      // Check if user needs verification (this includes both successful login and unverified user cases)
      if (result['success'] || result['error']?.contains('not verified') == true) {
        AppLogger.info('📱 [LOGIN] Navigating to OTP view for verification');
        // Navigate to OTP verification
        await Get.toNamed(
          AppRoutes.otp, 
          arguments: {
            'target': emailController.text.trim(), 
            'type': 'email',
            'source': 'login'
          }
        );
        AppLogger.success('✅ [LOGIN] Navigation to OTP completed');
      } else {
        // Handle other error cases (invalid email, server error, etc)
        AppLogger.warning('⚠️ [LOGIN] Login failed: ${result['error']}');
        errorMessage.value = result['error'] ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }
  
  VoidCallback? get onLoginPressed => isLoading.value ? null : () => login();
  
  void clearError() {
    errorMessage.value = '';
  }
  
  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
