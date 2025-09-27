import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../models/create_chat.dart';

class CreateChatService {
  final Dio _dio;

  CreateChatService(this._dio);

  /// Create a new chat with the specified participants
  /// 
  /// [participants] - List of user IDs to include in the chat
  /// Returns CreateChatResponse with the created chat data
  Future<CreateChatResponse> createChat({
    required List<String> participants,
  }) async {
    try {
      AppLogger.info('=== CREATE CHAT SERVICE ===');
      AppLogger.info('Creating chat with participants: $participants');
      
      // Get authentication token
      final token = LocalStorage.token;
      if (token.isEmpty) {
        AppLogger.error('No authentication token found');
        throw Exception('Authentication token is required');
      }
      
      // Prepare request data
      final requestData = {
        'participants': participants,
      };
      
      AppLogger.info('Request data: $requestData');
      
      // Make API call
      final response = await _dio.post(
        '${AppUrls.baseUrl}${AppUrls.createChat}',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      AppLogger.info('Create chat response status: ${response.statusCode}');
      AppLogger.info('Create chat response data: ${response.data}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final createChatResponse = CreateChatResponse.fromJson(response.data);
        AppLogger.info('Chat created successfully with ID: ${createChatResponse.data.id}');
        return createChatResponse;
      } else {
        AppLogger.error('Failed to create chat. Status code: ${response.statusCode}');
        throw Exception('Failed to create chat: ${response.statusCode}');
      }
      
    } on DioException catch (e) {
      AppLogger.error('DioException in createChat: ${e.message}');
      AppLogger.error('Response data: ${e.response?.data}');
      AppLogger.error('Status code: ${e.response?.statusCode}');
      
      String errorMessage = 'Failed to create chat';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid request: ${e.response?.data['message'] ?? 'Bad request'}';
      } else if (e.response?.statusCode == 404) {
        errorMessage = 'Chat creation endpoint not found';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error occurred while creating chat';
      } else if (e.type == DioExceptionType.connectionTimeout || 
                 e.type == DioExceptionType.sendTimeout || 
                 e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Network timeout. Please check your connection and try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network connection error. Please check your internet connection.';
      }
      
      AppLogger.error('Create chat error message: $errorMessage');
      throw Exception(errorMessage);
      
    } catch (e) {
      AppLogger.error('Unexpected error in createChat: $e');
      throw Exception('An unexpected error occurred while creating chat: $e');
    }
  }

  /// Create a chat between two users (convenience method)
  /// 
  /// [userId1] - First user ID
  /// [userId2] - Second user ID
  /// Returns CreateChatResponse with the created chat data
  Future<CreateChatResponse> createOneOnOneChat({
    required String userId1,
    required String userId2,
  }) async {
    return createChat(participants: [userId1, userId2]);
  }

  /// Create a chat with the suggested user from home suggestion
  /// 
  /// [suggestedUserId] - The ID of the suggested user
  /// Returns CreateChatResponse with the created chat data
  Future<CreateChatResponse> createChatWithSuggestedUser({
    required String suggestedUserId,
  }) async {
    final currentUserId = LocalStorage.userId;
    
    if (currentUserId.isEmpty) {
      AppLogger.error('No current user ID found in LocalStorage');
      throw Exception('Current user ID is required');
    }
    
    AppLogger.info('Creating chat between current user ($currentUserId) and suggested user ($suggestedUserId)');
    
    return createOneOnOneChat(
      userId1: suggestedUserId, // Suggested user first as per requirement
      userId2: currentUserId,   // Current user second
    );
  }
}