import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/core/utils/jwt_util.dart';

class MessageViewGetChatListService {
  final Dio _dio = Dio();

  // Function to get chat list with Bearer token
  Future<Map<String, dynamic>> getChatList(String token) async {
    try {
      // Get current user ID for logging purposes
      String userId = LocalStorage.userId;
      AppLogger.info('[CHAT SERVICE] User ID from LocalStorage: "$userId"');
      
      // If user ID is not in LocalStorage, try to extract it from JWT token
      if (userId.isEmpty) {
        AppLogger.info('[CHAT SERVICE] No user ID in LocalStorage, trying to extract from JWT token');
        final tokenUserId = JwtUtil.getUserIdFromToken(token);
        if (tokenUserId != null && tokenUserId.isNotEmpty) {
          userId = tokenUserId;
          AppLogger.success('[CHAT SERVICE] Successfully extracted user ID from JWT: $userId');
          
          // Save the extracted user ID to LocalStorage for future use
          try {
            await LocalStorage.setString(LocalStorageKeys.userId, userId);
            LocalStorage.userId = userId;
            AppLogger.info('[CHAT SERVICE] Saved extracted user ID to LocalStorage');
          } catch (e) {
            AppLogger.error('[CHAT SERVICE] Failed to save user ID to LocalStorage: $e');
          }
        } else {
          AppLogger.warning('[CHAT SERVICE] Could not extract user ID from JWT token');
        }
      }
      
      // Build URL without query parameters - let the backend handle authentication via token
      String url = '${AppUrls.baseUrl}${AppUrls.getChatList}';
      AppLogger.info('[CHAT SERVICE] Making request to: $url');
      AppLogger.info('[CHAT SERVICE] User ID for context: $userId');
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      // If response is successful, return data
      AppLogger.info('[CHAT SERVICE] Chat list loaded successfully');
      AppLogger.info('[CHAT SERVICE] Response data: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      // Handle Dio error
      if (e.response != null) {
        // Server error response
        AppLogger.error('[CHAT SERVICE] Server error: ${e.response?.statusCode} - ${e.response?.data}');
        throw Exception('Failed to load chat list: ${e.response?.data}');
      } else {
        // Network error
        AppLogger.error('[CHAT SERVICE] Network error: ${e.message}');
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      // Handle other errors
      AppLogger.error('[CHAT SERVICE] Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}