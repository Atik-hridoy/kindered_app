import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/auth/service/create_account.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';

class CreateAccountViewController extends GetxController {
  final emailController = TextEditingController();
  final RxBool isLoading = false.obs;

  late final CreateAccountService _createAccountService;

  @override
  void onInit() {
    super.onInit();
    _createAccountService = CreateAccountService(Dio());
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  VoidCallback get onNextPressed => () async {
        if (isLoading.value) return;

        final email = emailController.text.trim();

        // Validate email
        if (email.isEmpty) {
          _showError('Please enter your email');
          return;
        }

        final emailRegex =
            RegExp(r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');
        if (!emailRegex.hasMatch(email)) {
          _showError('Please enter a valid email');
          return;
        }

        try {
          isLoading.value = true;
          AppLogger.info('👤 Starting account creation for email: $email');

          final response = await _createAccountService.createAccount(email: email);

          if (response['success'] == true || response['status'] == 'success') {
            // Save email locally after successful account creation
            await LocalStorage.setString(LocalStorageKeys.myEmail, email);
            LocalStorage.myEmail = email; // Update in-memory cache
            
            AppLogger.info('💾 Email saved locally: $email');
            _showSuccess('Account created successfully!');
            await Future.delayed(const Duration(seconds: 2));
            Get.toNamed(AppRoutes.otp,
                arguments: {'target': email, 'type': 'email', 'source': 'register'});
          } else {
            _showError(response['message'] ?? 'Failed to create account');
          }
        } on DioException catch (e) {
          AppLogger.error(
              '❌ Dio error during account creation: ${e.message}', e, e.stackTrace);
          AppLogger.api('POST', '/auth/register',
              statusCode: e.response?.statusCode);

          String errorMessage = 'Failed to create account';
          if (e.response?.data != null) {
            errorMessage = e.response?.data['message'] ?? errorMessage;
          } else if (e.message != null) {
            errorMessage = e.message ?? errorMessage;
          }

          _showError(errorMessage);
        } catch (e) {
          AppLogger.error('❌ Unexpected error during account creation: $e');
          _showError('An unexpected error occurred. Please try again.');
        } finally {
          isLoading.value = false;
        }
      };

  void _showError(String message) {
    AppLogger.warning('⚠️ Showing error to user: $message');
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccess(String message) {
    AppLogger.success('✅ Showing success to user: $message');
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
