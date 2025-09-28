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
      
      // Clear any existing Authorization header to ensure clean login request
      _dio.options.headers.remove('Authorization');
      
      final response = await _dio.post(
        AppUrls.login,
        data: {
          'email': email,
        },
      );
      
      AppLogger.info('📝 [AUTH SERVICE] Server response: ${response.data}');
      
      // Log detailed response structure for debugging
      AppLogger.info('📋 [LOGIN DEBUG] Full response structure:');
      AppLogger.info('   - Success: ${response.data['success']}');
      AppLogger.info('   - Status: ${response.data['status']}');
      AppLogger.info('   - Message: ${response.data['message']}');
      
      if (response.data['data'] != null) {
        AppLogger.info('   - Data keys: ${(response.data['data'] as Map).keys.toList()}');
        if (response.data['data']['user'] != null) {
          AppLogger.info('   - User data: ${response.data['data']['user']}');
        }
        if (response.data['data']['isVerified'] != null) {
          AppLogger.info('   - IsVerified: ${response.data['data']['isVerified']}');
        }
        if (response.data['data']['verified'] != null) {
          AppLogger.info('   - Verified: ${response.data['data']['verified']}');
        }
      }
      
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

  /// Validate saved authentication token
  Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      AppLogger.info('🔐 [AUTH SERVICE] Validating saved token...');
      
      // Set Authorization header with saved token
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      // Make a request to validate the token (you can use any protected endpoint)
      // For now, we'll use a simple user profile endpoint or create a dedicated validate endpoint
      final response = await _dio.get(
        '${AppUrls.baseUrl}/auth/validate', // You may need to create this endpoint
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      
      AppLogger.success('✅ [AUTH SERVICE] Token validation successful');
      return {
        'success': true,
        'data': response.data,
      };
    } on DioException catch (e) {
      AppLogger.warning('⚠️ [AUTH SERVICE] Token validation failed: ${e.response?.statusCode}');
      
      // Check if it's a 401 Unauthorized error (token expired/invalid)
      if (e.response?.statusCode == 401) {
        return {
          'success': false,
          'error': 'Token expired or invalid',
          'needsRefresh': true,
        };
      }
      
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'Token validation failed',
      };
    } catch (e) {
      AppLogger.error('❌ [AUTH SERVICE] Unexpected error during token validation: $e');
      return {
        'success': false,
        'error': 'Token validation failed',
      };
    }
  }

  /// Alternative token validation using login endpoint (fallback)
  Future<Map<String, dynamic>> validateTokenWithLogin(String email, String token) async {
    try {
      AppLogger.info('🔄 [AUTH SERVICE] Validating token with login endpoint for: $email');
      
      // Try to login with the saved email to check if user exists and token is still valid
      final loginResult = await login(email);
      
      if (loginResult['success'] == true) {
        // User exists, now check if we can access a protected resource with the token
        _dio.options.headers['Authorization'] = 'Bearer $token';
        
        try {
          // Try to access a protected endpoint
          final response = await _dio.get(
            '${AppUrls.baseUrl}/user/profile', // Example protected endpoint
            options: Options(
              headers: {
                'Authorization': 'Bearer $token',
              },
            ),
          );
          
          AppLogger.success('✅ [AUTH SERVICE] Token validation with login successful');
          return {
            'success': true,
            'data': response.data,
          };
        } on DioException catch (e) {
          if (e.response?.statusCode == 401) {
            AppLogger.warning('⚠️ [AUTH SERVICE] Token is invalid, needs refresh');
            return {
              'success': false,
              'error': 'Token expired or invalid',
              'needsRefresh': true,
            };
          }
          return {
            'success': false,
            'error': 'Token validation failed',
          };
        }
      } else {
        return loginResult; // Return the login error
      }
    } catch (e) {
      AppLogger.error('❌ [AUTH SERVICE] Error during token validation with login: $e');
      return {
        'success': false,
        'error': 'Token validation failed',
      };
    }
  }
}