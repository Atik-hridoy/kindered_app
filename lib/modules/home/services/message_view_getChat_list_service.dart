import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';

class MessageViewGetChatListService {
  final Dio _dio = Dio();

  // Function to get chat list with Bearer token
  Future<Map<String, dynamic>> getChatList(String token) async {
    try {
      final response = await _dio.get(
        '${AppUrls.baseUrl}${AppUrls.getChatList}',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // If response is successful, return data
      return response.data;
    } on DioException catch (e) {
      // Handle Dio error
      if (e.response != null) {
        // Server error response
        print('Error: ${e.response?.data}');
        throw Exception('Failed to load chat list: ${e.response?.data}');
      } else {
        // Network error
        print('Network error: ${e.message}');
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
