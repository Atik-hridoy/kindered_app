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
    if (phoneController.text.isNotEmpty) {
      final fullNumber = '$countryCode${phoneController.text}';
      Get.toNamed(AppRoutes.otp);
    } else {
      // Show error if phone number is empty
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}