import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EducationController extends GetxController {
  final educationController = TextEditingController();
  final jobStatusController = TextEditingController();
  final incomeController = TextEditingController();
  
  final RxBool isButtonEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Add listeners to all controllers
    educationController.addListener(validateInputs);
    jobStatusController.addListener(validateInputs);
    incomeController.addListener(validateInputs);
  }

  @override
  void onClose() {
    // Dispose all controllers
    educationController.dispose();
    jobStatusController.dispose();
    incomeController.dispose();
    super.onClose();
  }

  void validateInputs() {
    // Enable button if all required fields are not empty
    isButtonEnabled.value = educationController.text.trim().isNotEmpty &&
                          jobStatusController.text.trim().isNotEmpty &&
                          incomeController.text.trim().isNotEmpty;
  }
  
  // Method to get all the form data
  Map<String, dynamic> getFormData() {
    return {
      'education': educationController.text.trim(),
      'jobStatus': jobStatusController.text.trim(),
      'income': incomeController.text.trim(),
    };
  }
}
