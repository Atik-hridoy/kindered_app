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
    // Add listeners to validate inputs
    educationController.addListener(validateInputs);
    jobStatusController.addListener(validateInputs);
    incomeController.addListener(validateInputs);
  }

  @override
  void onClose() {
    educationController.dispose();
    jobStatusController.dispose();
    incomeController.dispose();
    super.onClose();
  }

  /// Validate that all inputs are non-empty
  void validateInputs() {
    isButtonEnabled.value = educationController.text.trim().isNotEmpty &&
                            jobStatusController.text.trim().isNotEmpty &&
                            incomeController.text.trim().isNotEmpty;
  }

  /// Retrieve form data as a Map (string values, numbers as strings)
  Map<String, String> getFormData() {
    return {
      'education': educationController.text.trim(),
      'jobStatus': jobStatusController.text.trim(),
      'income': incomeController.text.trim(),
    };
  }
}
