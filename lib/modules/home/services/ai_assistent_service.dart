import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
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
      
      final response = await _dio.get(
        AppUrls.aiMatchmakingDefault,
      );

      // Log the API response

      // Parse the response using the model
      final matchmakingResponse = MatchmakingResponse.fromJson(response.data);
      
      return matchmakingResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
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

      
      final response = await _dio.post(
        AppUrls.aiQuickQuestions,
        data: payload,
      );

      // Log the API response

      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
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

      
      final response = await _dio.post(
        '${AppUrls.aiMatchmakingDefault}/action',
        data: payload,
      );

      // Log the API response

      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
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

      
      final response = await _dio.post(
        AppUrls.aiNextMatch,
        data: payload,
      );

      // Log the API response

      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
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

      
      final response = await _dio.post(
        AppUrls.aiMatchmakingDefault,
        data: payload,
      );

      // Log the API response

      return response.data as Map<String, dynamic>;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get user's AI matchmaking history
  Future<List<Map<String, dynamic>>> getMatchmakingHistory() async {
    try {
      
      final response = await _dio.get(
        '${AppUrls.aiMatchmakingDefault}/history',
      );

      // Log the API response

      return (response.data['data'] as List?)?.map((e) => e as Map<String, dynamic>).toList() ?? [];
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Update Dio headers with new token
  void updateToken(String newToken) {
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }

  /// Check if user is authenticated
  bool get isAuthenticated => LocalStorage.token.isNotEmpty;

  /// Get current token
  String get currentToken => LocalStorage.token;

  /// Get AI quick questions
  /// Returns a list of quick questions for AI assistant
  Future<List<String>> getQuickQuestions() async {
    try {
      
      // Send empty payload as some servers require it for POST requests
      final response = await _dio.post(
        AppUrls.aiQuickQuestions,
        data: {}, // Empty payload to satisfy server requirements
      );

      // Log the API response

      // Parse the response - assuming it returns a list of questions
      List<String> questions = [];
      if (response.data is List) {
        questions = List<String>.from(response.data);
      }
      
      return questions;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
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

      
      final response = await _dio.post(
        AppUrls.aiChatWithAi,
        data: payload,
      );

      // Log the API response

      // Parse the response using the ChatWithAI model
      final chatResponse = ChatWithAIResponse.fromJson(response.data);
      
      return chatResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      
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
    } catch (e) {
      // Log any other errors
      throw Exception('An unexpected error occurred: $e');
    }
  }
}