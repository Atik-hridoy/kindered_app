import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../models/ai_assistent_get_model.dart';

class AiAssistentService {
  final Dio _dio;

  AiAssistentService() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: {
      'Authorization': 'Bearer ${LocalStorage.token}',
      'Content-Type': 'application/json',
    },
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

      AppLogger.api('POST', '${AppUrls.aiMatchmakingDefault}/chat', data: payload);
      
      final response = await _dio.post(
        '${AppUrls.aiMatchmakingDefault}/chat',
        data: payload,
      );

      // Log the API response
      AppLogger.api(
        'POST',
        '${AppUrls.aiMatchmakingDefault}/chat',
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
}