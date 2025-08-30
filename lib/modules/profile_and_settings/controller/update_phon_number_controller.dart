import 'package:get/get.dart';
import 'package:flutter/material.dart';

class UpdatePhonNumberController extends GetxController {
  late final TextEditingController phoneController;
  final RxString countryCode = '+880'.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void clear() {
    phoneController.clear();
  }
}