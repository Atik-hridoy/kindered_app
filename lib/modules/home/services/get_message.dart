import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/home/models/get_message_model.dart';

class GetMessageService {
  final Dio _dio = Dio();

  /// Get messages for a specific chat
  /// 
  /// Parameters:
  /// - [chatId]: The ID of the chat to get messages from
  /// - [page]: Page number for pagination (optional, default: 1)
  /// - [limit]: Number of messages per page (optional, default: 50)
  /// 
  /// Returns a GetMessageResponse containing the server response
  Future<GetMessageResponse> getMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      // Get authentication token
      final token = LocalStorage.token;
      
      if (token.isEmpty) {
        AppLogger.error('[GET MESSAGE SERVICE] No authentication token found');
        throw Exception('Authentication required. Please login again.');
      }
      
      AppLogger.info('[GET MESSAGE SERVICE] Getting messages for chat: $chatId');
      AppLogger.info('[GET MESSAGE SERVICE] Page: $page, Limit: $limit');
      
      // Replace the :chatId placeholder in the URL with the actual chat ID
      final endpoint = AppUrls.getMessages.replaceAll(':chatId', chatId);
      final url = '${AppUrls.baseUrl}$endpoint';
      
      // Add query parameters for pagination
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      AppLogger.info('[GET MESSAGE SERVICE] Making GET request to: $url');
      AppLogger.info('[GET MESSAGE SERVICE] Query parameters: $queryParams');
      
      // Make the GET request
      final response = await _dio.get(
        url,
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      AppLogger.info('[GET MESSAGE SERVICE] Response status: ${response.statusCode}');
      AppLogger.info('[GET MESSAGE SERVICE] Response data: ${response.data}');
      
      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final getMessageResponse = GetMessageResponse.fromJson(response.data);
        AppLogger.info('[GET MESSAGE SERVICE] Messages retrieved successfully');
        AppLogger.info('[GET MESSAGE SERVICE] Total messages: ${getMessageResponse.data.messages.length}');
        return getMessageResponse;
      } else {
        AppLogger.error('[GET MESSAGE SERVICE] Unexpected status code: ${response.statusCode}');
        throw Exception('Failed to get messages. Status code: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      AppLogger.error('[GET MESSAGE SERVICE] DioException occurred: ${e.message}');
      AppLogger.error('[GET MESSAGE SERVICE] Error type: ${e.type}');
      AppLogger.error('[GET MESSAGE SERVICE] Error response: ${e.response?.data}');
      
      String errorMessage = 'Failed to get messages';
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Network timeout. Please check your connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network connection error. Please check your internet connection.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Chat not found.';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later.';
      } else if (e.response?.data != null && e.response?.data['message'] != null) {
        errorMessage = e.response?.data['message'];
      }
      
      throw Exception(errorMessage);
      
    } catch (e) {
      AppLogger.error('[GET MESSAGE SERVICE] Unexpected error occurred: $e');
      throw Exception('An unexpected error occurred while getting messages: $e');
    }
  }

  /// Convenience method to get all messages for a chat (without pagination limits)
  /// 
  /// This method will make multiple requests if needed to get all messages
  Future<GetMessageResponse> getAllMessages({
    required String chatId,
    int batchSize = 100,
  }) async {
    try {
      AppLogger.info('[GET MESSAGE SERVICE] Getting all messages for chat: $chatId');
      
      List<Message> allMessages = [];
      int currentPage = 1;
      bool hasMoreMessages = true;
      
      while (hasMoreMessages) {
        final response = await getMessages(
          chatId: chatId,
          page: currentPage,
          limit: batchSize,
        );
        
        final messages = response.data.messages;
        allMessages.addAll(messages);
        
        AppLogger.info('[GET MESSAGE SERVICE] Retrieved ${messages.length} messages (page $currentPage)');
        
        // If we got fewer messages than the batch size, we've reached the end
        if (messages.length < batchSize) {
          hasMoreMessages = false;
        } else {
          currentPage++;
        }
      }
      
      AppLogger.info('[GET MESSAGE SERVICE] Total messages retrieved: ${allMessages.length}');
      
      // Create a combined response with all messages
      return GetMessageResponse(
        success: true,
        message: 'All messages retrieved successfully',
        statusCode: 200,
        data: GetMessageData(messages: allMessages, pinnedMessages: []),
      );
      
    } catch (e) {
      AppLogger.error('[GET MESSAGE SERVICE] Error getting all messages: $e');
      rethrow;
    }
  }

  /// Convenience method to get latest messages for a chat
  /// 
  /// Parameters:
  /// - [chatId]: The ID of the chat to get messages from
  /// - [limit]: Number of latest messages to retrieve (default: 20)
  Future<GetMessageResponse> getLatestMessages({
    required String chatId,
    int limit = 20,
  }) async {
    try {
      AppLogger.info('[GET MESSAGE SERVICE] Getting latest messages for chat: $chatId');
      
      final response = await getMessages(
        chatId: chatId,
        page: 1,
        limit: limit,
      );
      
      AppLogger.info('[GET MESSAGE SERVICE] Retrieved ${response.data.messages.length} latest messages');
      
      return response;
      
    } catch (e) {
      AppLogger.error('[GET MESSAGE SERVICE] Error getting latest messages: $e');
      rethrow;
    }
  }
}