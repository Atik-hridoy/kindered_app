import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeightWeightController extends GetxController {
  // Text editing controllers
  final heightController = TextEditingController();
  final weightController = TextEditingController();

  // Validation state
  final isHeightValid = false.obs;
  final isWeightValid = false.obs;

  /// Dispose controllers when done
  @override
  void onClose() {
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }

  /// Validate inputs: non-empty strings
  void validateInputs() {
    isHeightValid.value = heightController.text.trim().isNotEmpty;
    isWeightValid.value = weightController.text.trim().isNotEmpty;
  }

  /// Check if both inputs are valid
  bool get areInputsValid => isHeightValid.value && isWeightValid.value;
}
