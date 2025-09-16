import 'package:dio/dio.dart';
import '../../../core/app_urls.dart';

class CreateAccountService {
  final Dio _dio;

  CreateAccountService(this._dio);

  Future<Map<String, dynamic>> createAccount({
    required String email,
  }) async {
    try {
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.createAccount}',
        data: {
          'email': email,
        },
      );

      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to create account: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}