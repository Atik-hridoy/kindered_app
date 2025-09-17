import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart'; 

class AccountSetupService {
  final Dio _dio;

  AccountSetupService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

  /// Complete Profile POST request
  Future<Response> completeProfile(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        AppUrls.completeProfile,
        data: data,
      );
      return response;
    } on DioError catch (e) {
      // You can customize error handling
      throw Exception(e.response?.data ?? e.message);
    }
  }
}
