import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../service/login.dart';
import 'package:kindered_app/local/storage_service.dart';

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
    
    final email = emailController.text.trim();
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      AppLogger.info('🔄 [LOGIN] Attempting login with email: $email');
      
      // First check if we have saved tokens for this email
      final savedEmail = LocalStorage.myEmail;
      final savedToken = LocalStorage.token;
      final isAuthenticated = LocalStorage.isAuthenticated();
      
      AppLogger.info('📋 [LOGIN] Checking saved auth data:');
      AppLogger.info('   - Input email: $email');
      AppLogger.info('   - Saved email: $savedEmail');
      AppLogger.info('   - Has saved token: ${savedToken.isNotEmpty}');
      AppLogger.info('   - Is authenticated: $isAuthenticated');
      
      // If we have saved data for this email, try auto-login
      if (isAuthenticated && savedEmail == email && savedToken.isNotEmpty) {
        AppLogger.info('🚀 [LOGIN] Found saved auth data for this email, attempting auto-login...');
        
        // Validate the saved token
        final tokenValidationResult = await _authService.validateTokenWithLogin(email, savedToken);
        
        if (tokenValidationResult['success'] == true) {
          // Token is valid, navigate directly to home
          AppLogger.success('✅ [LOGIN] Auto-login successful! Navigating to home...');
          Get.offAllNamed(AppRoutes.locationView);
          return;
        } else if (tokenValidationResult['needsRefresh'] == true) {
          // Token expired, need to get new one via OTP
          AppLogger.info('⏰ [LOGIN] Token expired, need OTP verification');
        } else {
          // Invalid token, clear and proceed with normal login
          AppLogger.warning('⚠️ [LOGIN] Invalid saved token, clearing and proceeding with normal login');
          await LocalStorage.clearAll();
        }
      }
      
      // If no saved data or auto-login failed, proceed with normal login flow
      AppLogger.info('📧 [LOGIN] Proceeding with normal login flow for: $email');
      final result = await _authService.login(email);
      
      AppLogger.info('📝 [LOGIN] Server response: $result');
      
      // Check if user needs verification (this includes both successful login and unverified user cases)
      if (result['success'] == true) {
        AppLogger.info('📱 [LOGIN] Login successful, navigating to OTP view for verification');
        // Navigate to OTP verification
        await Get.toNamed(
          AppRoutes.otp, 
          arguments: {
            'target': email, 
            'type': 'email',
            'source': 'login'
          }
        );
        AppLogger.success('✅ [LOGIN] Navigation to OTP completed');
      } else if (result['error']?.contains('not verified') == true || result['error']?.contains('User not verified') == true) {
        AppLogger.info('📱 [LOGIN] User not verified, navigating to OTP view');
        // Show user-friendly message about verification
        Get.snackbar(
          'Verification Required',
          'Please verify your email to continue. Check your email for the OTP code.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
        
        // Navigate to OTP verification
        await Get.toNamed(
          AppRoutes.otp, 
          arguments: {
            'target': email, 
            'type': 'email',
            'source': 'login'
          }
        );
        AppLogger.success('✅ [LOGIN] Navigation to OTP completed for unverified user');
      } else {
        // Handle other error cases (invalid email, server error, etc)
        AppLogger.warning('⚠️ [LOGIN] Login failed: ${result['error']}');
        errorMessage.value = result['error'] ?? 'Login failed. Please try again.';
      }
    } catch (e) {
      AppLogger.error('❌ [LOGIN] Unexpected error: $e');
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
