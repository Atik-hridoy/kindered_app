import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import '../service/otp.dart';
import 'package:kindered_app/modules/acccounts_setting/controller/accounts_controller.dart';


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
    
    // Validate that OTP contains only numeric characters
    if (!RegExp(r'^\d+$').hasMatch(otpCode)) {
      Get.snackbar('Error', 'OTP must contain only numbers.');
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
        // Save email locally for both register and login flows
        await LocalStorage.setString(LocalStorageKeys.myEmail, target.value);
        LocalStorage.myEmail = target.value; // Update in-memory cache
        AppLogger.info('💾 Email saved locally: ${target.value}');
        
        // Save all authentication tokens from response
        try {
          final data = response['data'];
          String? accessToken;
          String? refreshToken;
          String? cookie;
          String? userId;
          
          // Extract tokens from response data (support multiple possible key names)
          if (data is Map) {
            // Access token - try multiple possible keys
            accessToken = data['token'] ?? data['accessToken'] ?? data['access_token'] ?? data['jwt'] ?? data['bearer'];
            
            // Refresh token
            refreshToken = data['refreshToken'] ?? data['refresh_token'];
            
            // Cookie
            cookie = data['cookie'] ?? data['session'];
            
            // User ID
            userId = data['userId'] ?? data['user_id'] ?? data['id'];
          }
          
          // Also check for tokens at the root level
          accessToken ??= response['token'] ?? response['accessToken'] ?? response['access_token'];
          refreshToken ??= response['refreshToken'] ?? response['refresh_token'];
          cookie ??= response['cookie'] ?? response['session'];
          userId ??= response['userId'] ?? response['user_id'] ?? response['id'];
          
          if (accessToken != null && accessToken.isNotEmpty) {
            // Save all tokens using the enhanced storage method
            await LocalStorage.saveAuthTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
              cookie: cookie,
              userId: userId,
            );
            
            AppLogger.success('✅ All authentication tokens saved successfully');
            AppLogger.info('🔐 Access token: ${accessToken.length} chars');
            if (refreshToken != null) {
              AppLogger.info('🔄 Refresh token: ${refreshToken.length} chars');
            }
            if (cookie != null) {
              AppLogger.info('🍪 Cookie: ${cookie.length} chars');
            }
            if (userId != null) {
              AppLogger.info('👤 User ID: $userId');
            }

            // Initialize AccountsController service with fresh token if available
            if (Get.isRegistered<AccountsController>()) {
              try {
                final acc = Get.find<AccountsController>();
                acc.initializeAccountSetupService(LocalStorage.token);
                AppLogger.info('🔗 AccountsController initialized with bearer token after OTP');
              } catch (e) {
                AppLogger.warning('⚠️ Failed to init AccountsController after OTP: $e');
              }
            }
          } else {
            AppLogger.warning('⚠️ No access token found in OTP response');
            AppLogger.info('📋 Full response: $response');
          }
        } catch (e) {
          AppLogger.error('❌ Error saving authentication tokens: $e');
        }
        
        // Navigate based on source
        try {
          if (source.value == 'login') {
            // From email login view - go to home suggestion view
            Get.offAllNamed(AppRoutes.locationView);
          } else {
            // From create account view - go to intro view
            Get.offAllNamed(AppRoutes.intro);
          }
        } catch (e) {
          AppLogger.error('❌ Navigation error after OTP verification: $e');
          Get.snackbar('Error', 'Failed to navigate to next screen.');
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
    if (target.value.isEmpty || type.value.isEmpty) {
      Get.snackbar('Error', 'Missing required information for resending OTP.');
      return;
    }
    
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
