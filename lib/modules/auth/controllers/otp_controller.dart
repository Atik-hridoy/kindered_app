import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import '../service/otp.dart';


class OtpController extends GetxController {
  static OtpController get to => Get.find();

  final target = ''.obs; // email or phone
  final type = ''.obs;   // 'email'
  final source = ''.obs; // 'login' or 'register'
  final otpDigits = List.generate(4, (_) => ''.obs);
  final isLoading = false.obs;

  late final OtpService _otpService;

  @override
  void onInit() {
    super.onInit();
    _otpService = OtpService(Dio());
    final args = Get.arguments;
    if (args is Map) {
      target.value = args['target']?.toString() ?? '';
      type.value = args['type']?.toString() ?? 'email';
      source.value = args['source']?.toString() ?? 'login';
    }
  }

  String get otpCode => otpDigits.map((e) => e.value).join();

  Future<void> verifyOtp() async {
    if (otpCode.length < 4) {
      Get.snackbar('Error', 'Please enter the full OTP.');
      return;
    }
    isLoading.value = true;
    try {
      final response = await _otpService.verifyOtp(
        email: target.value,
        oneTimeCode: int.parse(otpCode),
      );
      
      AppLogger.success('✅ Verification Success: $response');
      
      // Check if verification was successful
      if (response['success'] == true || response['status'] == 'success') {
        // Save email locally if coming from login flow
        if (source.value == 'login') {
          await LocalStorage.setString(LocalStorageKeys.myEmail, target.value);
          LocalStorage.myEmail = target.value; // Update in-memory cache
          AppLogger.info('💾 Email saved locally from login: ${target.value}');
        }
        
        // Save user session/token if provided in response
        if (response['data'] != null && response['data']['token'] != null) {
          await LocalStorage.setString(LocalStorageKeys.token, response['data']['token']);
          LocalStorage.token = response['data']['token'];
          await LocalStorage.setBool(LocalStorageKeys.isLogIn, true);
          LocalStorage.isLogIn = true;
          AppLogger.info('🔐 User session saved');
        }
        
        // Navigate based on source
        if (source.value == 'login') {
          // From email login view - go to home suggestion view
          Get.offAllNamed(AppRoutes.homeSuggestionView);
        } else {
          // From create account view - go to intro view
          Get.offAllNamed(AppRoutes.intro);
        }
      } else {
        AppLogger.error('❌ Verification failed: ${response['message'] ?? 'Unknown error'}');
        Get.snackbar('Error', response['message'] ?? 'Failed to verify OTP.');
      }
    } catch (e) {
      AppLogger.error('❌ Verification failed: $e');
      Get.snackbar('Error', 'Failed to verify OTP.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    isLoading.value = true;
    try {
      final response = await _otpService.resendOtp(
        target: target.value,
        type: type.value,
      );
      AppLogger.success('✅ OTP resent: $response');
      Get.snackbar('Success', 'OTP resent successfully.');
    } catch (e) {
      AppLogger.error('❌ Failed to resend OTP: $e');
      Get.snackbar('Error', 'Failed to resend OTP.');
    } finally {
      isLoading.value = false;
    }
  }
}
