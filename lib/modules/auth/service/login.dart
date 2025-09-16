import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  Future<Map<String, dynamic>> login(String email) async {
    try {
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.login}',
        data: {
          'email': email,
        },
      );
      
      // Check if email exists and OTP can be sent
      if (response.data['success'] == true || response.data['status'] == 'success') {
        return {
          'success': true,
          'message': response.data['message'] ?? 'OTP sent successfully',
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'error': response.data['message'] ?? 'Email not found or login failed',
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
        '${AppUrls.baseUrl}${AppUrls.verifyOtp}',
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