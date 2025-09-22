import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<Map<String, dynamic>> login(String email) async {
    try {
      AppLogger.info('🔄 [AUTH SERVICE] Sending login request for email: $email');
      
      final response = await _dio.post(
        AppUrls.login,
        data: {
          'email': email,
        },
      );
      
      AppLogger.info('📝 [AUTH SERVICE] Server response: ${response.data}');
      
      // Check response status
      final bool isSuccess = response.data['success'] == true || response.data['status'] == 'success';
      final String message = response.data['message'] ?? '';
      
      // Handle both successful login and verification needed cases
      if (isSuccess || message.contains('not verified')) {
        AppLogger.success('✅ [AUTH SERVICE] Login request processed');
        return {
          'success': isSuccess,
          'message': message,
          'error': isSuccess ? null : message, // Include error message for unverified case
          'data': response.data,
          'needsVerification': message.contains('not verified')
        };
      } else {
        AppLogger.warning('⚠️ [AUTH SERVICE] Login request failed: $message');
        return {
          'success': false,
          'error': message.isEmpty ? 'Email not found or login failed' : message,
        };
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.message != null) {
        errorMessage = e.message ?? errorMessage;
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final response = await _dio.post(
        AppUrls.verifyOtp,
        data: {
          'email': email,
          'otp': otp,
        },
      );
      
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'OTP verification failed',
      };
    }
  }
}