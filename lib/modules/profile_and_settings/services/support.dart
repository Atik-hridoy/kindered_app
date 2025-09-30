import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/treamsOfService.dart';

class Support {
  final Dio _dio;

  Support(String token)
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

  Future<SettingResponse> getSupport() async {
    try {
      final response = await _dio.get(
        AppUrls.support,
      );

      return SettingResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Return error response
      return SettingResponse(
        success: false,
        message: e.message ?? 'Failed to fetch support',
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