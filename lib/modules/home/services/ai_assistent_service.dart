import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../models/ai_assistent_get_model.dart';
import '../models/chat_with_ai.dart';

class AiAssistentService {
  final Dio _dio;

  AiAssistentService() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: LocalStorage.getAuthHeaders(),
  ));

  /// Get AI matchmaking data
  /// Returns MatchmakingResponse with user matches and AI recommendations
  Future<MatchmakingResponse> getMatchmakingData() async {
    try {
      AppLogger.api('GET', AppUrls.aiMatchmakingDefault);
      
      final response = await _dio.get(
        AppUrls.aiMatchmakingDefault,
      );

      // Log the API response
      AppLogger.api(
        'GET',
        AppUrls.aiMatchmakingDefault,
        data: response.data,
        statusCode: response.statusCode,
      );

      // Parse the response using the model
      final matchmakingResponse = MatchmakingResponse.fromJson(response.data);
      
      AppLogger.success('✅ AI matchmaking data fetched successfully');
      return matchmakingResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ AI matchmaking request failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in AI matchmaking: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Process a quick question and get formatted response
  /// Returns a formatted response for the quick question
  Future<Map<String, dynamic>> processQuickQuestion({
    required String question,
  }) async {
    try {
      final payload = {
        'question': question,
      };

      AppLogger.api('POST', AppUrls.aiQuickQuestions, data: payload);
      
      final response = await _dio.post(
        AppUrls.aiQuickQuestions,
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.aiQuickQuestions,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ Quick question processed successfully');
      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Quick question processing failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in quick question processing: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Process discover action
  /// Returns a formatted response for the discover action
  Future<Map<String, dynamic>> processDiscoverAction() async {
    try {
      final payload = {
        'action': 'discover',
        'sessionId': LocalStorage.token, // Using token as session identifier
      };

      AppLogger.api('POST', '${AppUrls.aiMatchmakingDefault}/action', data: payload);
      
      final response = await _dio.post(
        '${AppUrls.aiMatchmakingDefault}/action',
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        '${AppUrls.aiMatchmakingDefault}/action',
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ Discover action processed successfully');
      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Discover action processing failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in discover action processing: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Process pass action
  /// Returns a formatted response for the pass action
  Future<Map<String, dynamic>> processPassAction() async {
    try {
      final payload = {
        'action': 'pass',
        'target_user_id': '68c512911c4bd141f4ba858c', // Target user ID for the match
      };

      AppLogger.api('POST', AppUrls.aiNextMatch, data: payload);
      
      final response = await _dio.post(
        AppUrls.aiNextMatch,
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.aiNextMatch,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ Pass action processed successfully');
      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Pass action processing failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in pass action processing: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Send AI chat message
  /// This can be extended to handle chat-based AI interactions
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final payload = {
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
      };

      AppLogger.api('POST', AppUrls.aiMatchmakingDefault, data: payload);
      
      final response = await _dio.post(
        AppUrls.aiMatchmakingDefault,
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.aiMatchmakingDefault,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ AI chat message sent successfully');
      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ AI chat message failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in AI chat: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get user's AI matchmaking history
  Future<List<Map<String, dynamic>>> getMatchmakingHistory() async {
    try {
      AppLogger.api('GET', '${AppUrls.aiMatchmakingDefault}/history');
      
      final response = await _dio.get(
        '${AppUrls.aiMatchmakingDefault}/history',
      );

      // Log the API response
      AppLogger.api(
        'GET',
        '${AppUrls.aiMatchmakingDefault}/history',
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ AI matchmaking history fetched successfully');
      return (response.data['data'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ AI matchmaking history failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in AI matchmaking history: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Update Dio headers with new token
  void updateToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
    AppLogger.info('🔐 AI Assistant service token updated');
  }

  /// Check if user is authenticated
  bool get isAuthenticated => LocalStorage.token.isNotEmpty;

  /// Get current token
  String get currentToken => LocalStorage.token;

  /// Get AI quick questions
  /// Returns a list of quick questions for AI assistant
  Future<List<String>> getQuickQuestions() async {
    try {
      AppLogger.api('POST', AppUrls.aiQuickQuestions);
      
      // Send empty payload as some servers require it for POST requests
      final response = await _dio.post(
        AppUrls.aiQuickQuestions,
        data: {}, // Empty payload to satisfy server requirements
      );

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.aiQuickQuestions,
        data: response.data,
        statusCode: response.statusCode,
      );

      // Parse the response - assuming it returns a list of questions
      List<String> questions = [];
      if (response.data is List) {
        questions = List<String>.from(response.data);
      }
      
      AppLogger.success('✅ AI quick questions fetched successfully');
      return questions;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ AI quick questions request failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in AI quick questions: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Chat with AI for matchmaking
  /// Sends a message to AI and gets matchmaking response with user message, AI response, and current match
  Future<ChatWithAIResponse> chatWithAI({
    required String message,
    String? sessionId,
  }) async {
    try {
      final payload = {
        'message': message,
        if (sessionId != null) 'sessionId': sessionId,
      };

      AppLogger.api('POST', AppUrls.aiChatWithAi, data: payload);
      
      final response = await _dio.post(
        AppUrls.aiChatWithAi,
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.aiChatWithAi,
        data: response.data,
        statusCode: response.statusCode,
      );

      // Parse the response using the ChatWithAI model
      final chatResponse = ChatWithAIResponse.fromJson(response.data);
      
      AppLogger.success('✅ AI chat matchmaking response fetched successfully');
      return chatResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ AI chat matchmaking request failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Request failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
      }
      
      throw Exception(errorMessage);
    } catch (e, stackTrace) {
      // Log any other errors
      AppLogger.error('❌ Unexpected error in AI chat matchmaking: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }
}