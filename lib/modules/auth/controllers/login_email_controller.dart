import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
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
      final result = await _authService.login(emailController.text.trim());
      
      if (result['success']) {
        // Login successful - navigate to OTP verification
        Get.toNamed(AppRoutes.otp, 
          arguments: {'target': emailController.text.trim(), 'type': 'email','source': 'login'});
      } else {
        errorMessage.value = result['error'];
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
