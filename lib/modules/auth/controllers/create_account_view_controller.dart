import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';

class CreateAccountViewController extends GetxController {
  final phoneController = TextEditingController();
  final countryCode = '+880'.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void onNextPressed() {
    final phoneNumber = phoneController.text.trim();
    
    // Validate phone number is not empty
    if (phoneNumber.isEmpty) {
      _showError('Please enter your phone number');
      return;
    }
    
    // Basic phone number validation (adjust the regex according to your needs)
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(phoneNumber)) {
      _showError('Please enter a valid phone number');
      return;
    }
    
    // If validation passes, navigate to OTP screen with the phone number
   
  }
  
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }
  }
