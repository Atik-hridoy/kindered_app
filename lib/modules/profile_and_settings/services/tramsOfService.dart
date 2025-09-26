import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/utils/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/model/treamsOfService.dart';
import 'package:kindered_app/local/storage_service.dart';

class TermsOfService {
  final Dio _dio;

  TermsOfService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: LocalStorage.getAuthHeaders(),
            validateStatus: (status) {
              return status! < 500;
            },
          ),
        ) {
    // Ensure the token is set correctly
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Get Terms of Service content
  Future<SettingResponse> getTermsOfService() async {
    try {
      AppLogger.info('📄 [TERMS OF SERVICE] Fetching terms of service...');
      
      final response = await _dio.get(
        AppUrls.termsOfService,
      );

      AppLogger.info('✅ [TERMS OF SERVICE] Terms of service fetched successfully');
      AppLogger.debug('📄 [TERMS OF SERVICE] Response: ${response.data}');

      return SettingResponse.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('❌ [TERMS OF SERVICE] DioException: ${e.message}');
      AppLogger.error('❌ [TERMS OF SERVICE] Response: ${e.response?.data}');
      AppLogger.error('❌ [TERMS OF SERVICE] Status code: ${e.response?.statusCode}');
      
      // Return error response
      return SettingResponse(
        success: false,
        message: e.message ?? 'Failed to fetch terms of service',
        statusCode: e.response?.statusCode ?? 500,
        data: '',
      );
    } catch (e) {
      AppLogger.error('❌ [TERMS OF SERVICE] Unexpected error: $e');
      
      // Return error response
      return SettingResponse(
        success: false,
        message: 'An unexpected error occurred',
        statusCode: 500,
        data: '',
      );
    }
  }

  /// Get Privacy Policy content
  Future<SettingResponse> getPrivacyPolicy() async {
    try {
      AppLogger.info('🔒 [PRIVACY POLICY] Fetching privacy policy...');
      
      final response = await _dio.get(
        AppUrls.privacyPolicy,
      );

      AppLogger.info('✅ [PRIVACY POLICY] Privacy policy fetched successfully');
      AppLogger.debug('🔒 [PRIVACY POLICY] Response: ${response.data}');

      return SettingResponse.fromJson(response.data);
    } on DioException catch (e) {
      AppLogger.error('❌ [PRIVACY POLICY] DioException: ${e.message}');
      AppLogger.error('❌ [PRIVACY POLICY] Response: ${e.response?.data}');
      AppLogger.error('❌ [PRIVACY POLICY] Status code: ${e.response?.statusCode}');
      
      // Return error response
      return SettingResponse(
        success: false,
        message: e.message ?? 'Failed to fetch privacy policy',
        statusCode: e.response?.statusCode ?? 500,
        data: '',
      );
    } catch (e) {
      AppLogger.error('❌ [PRIVACY POLICY] Unexpected error: $e');
      
      // Return error response
      return SettingResponse(
        success: false,
        message: 'An unexpected error occurred',
        statusCode: 500,
        data: '',
      );
    }
  }
}