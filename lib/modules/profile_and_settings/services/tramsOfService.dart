import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
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
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Get Terms of Service content
  Future<SettingResponse> getTermsOfService() async {
    try {
      final response = await _dio.get(
        AppUrls.termsOfService,
      );

      return SettingResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Return error response
      return SettingResponse(
        success: false,
        message: e.message ?? 'Failed to fetch terms of service',
        statusCode: e.response?.statusCode ?? 500,
        data: '',
      );
    } catch (e) {
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
      final response = await _dio.get(
        AppUrls.privacyPolicy,
      );

      return SettingResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Return error response
      return SettingResponse(
        success: false,
        message: e.message ?? 'Failed to fetch privacy policy',
        statusCode: e.response?.statusCode ?? 500,
        data: '',
      );
    } catch (e) {
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