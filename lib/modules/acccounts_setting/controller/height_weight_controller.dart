
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HeightWeightController extends GetxController {
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  
  final isHeightValid = false.obs;
  final isWeightValid = false.obs;
  
  @override
  void onClose() {
    heightController.dispose();
    weightController.dispose();
    super.onClose();
  }
  
  void validateInputs() {
    isHeightValid.value = heightController.text.isNotEmpty;
    isWeightValid.value = weightController.text.isNotEmpty;
  }
  
  bool get areInputsValid => isHeightValid.value && isWeightValid.value;
}
