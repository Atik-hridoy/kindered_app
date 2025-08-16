import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      // TODO: Implement phone number verification
      final fullNumber = '$countryCode${phoneController.text}';
      print('Verifying phone number: $fullNumber');
    }
  }
}