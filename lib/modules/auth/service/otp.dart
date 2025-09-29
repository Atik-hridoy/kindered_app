import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

class OtpService {
  final Dio _dio;

  OtpService(this._dio);

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required int oneTimeCode,
  }) async {
    try {
      AppLogger.info('🔐 Verifying OTP for $email');
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.verifyOtp}',
        data: {
          'email': email,
          'oneTimeCode': oneTimeCode,
        },
      );
      
      // Return consistent response format
      return {
        'success': response.data['success'] ?? response.data['status'] == 'success',
        'status': response.data['status'] ?? 'success',
        'message': response.data['message'] ?? 'OTP verified successfully',
        'data': response.data['data'] ?? response.data,
      };
    } on DioException catch (e) {
      AppLogger.error('❌ Dio error: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'OTP verification failed';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.message != null) {
        errorMessage = e.message ?? errorMessage;
      }
      
      return {
        'success': false,
        'status': 'error',
        'message': errorMessage,
        'error': errorMessage,
      };
    } catch (e) {
      AppLogger.error('❌ Unexpected error: $e');
      return {
        'success': false,
        'status': 'error',
        'message': 'An unexpected error occurred',
        'error': 'An unexpected error occurred',
      };
    }
  }

  Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) async {
    try {
      AppLogger.info('📧 Resending OTP for $email');
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.resendOtp}',
        data: {

          'email': email,
          
        },
      );
      
      // Return consistent response format
      return {
        'success': response.data['success'] ?? response.data['status'] == 'success',
        'status': response.data['status'] ?? 'success',
        'message': response.data['message'] ?? 'OTP resent successfully',
        'data': response.data['data'] ?? response.data,
      };
    } on DioException catch (e) {
      AppLogger.error('❌ Dio error: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'OTP resend failed';
      if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.message != null) {
        errorMessage = e.message ?? errorMessage;
      }
      
      return {
        'success': false,
        'status': 'error',
        'message': errorMessage,
        'error': errorMessage,
      };
    } catch (e) {
      AppLogger.error('❌ Unexpected error: $e');
      return {
        'success': false,
        'status': 'error',
        'message': 'An unexpected error occurred',
        'error': 'An unexpected error occurred',
      };
    }
  }
}