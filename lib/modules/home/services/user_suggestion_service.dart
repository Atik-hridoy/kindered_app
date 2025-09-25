import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../models/user_suggestion_model.dart';

class UserSuggestionService {
  final Dio _dio;

  UserSuggestionService() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: LocalStorage.getAuthHeaders(),
  ));

  /// Get authentication token
  String? get _authToken => LocalStorage.token.isNotEmpty ? LocalStorage.token : null;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// Get current match suggestion for photo card
  /// Returns UserSuggestionResponse with comprehensive match data
  Future<UserSuggestionResponse> getCurrentMatch() async {
    try {
      if (!isAuthenticated) {
        throw Exception('Authentication required');
      }

      final url = '${AppUrls.baseUrl}${AppUrls.aiCurrentMatch}';

      AppLogger.api('GET', url);
      
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Log the API response
      AppLogger.api(
        'GET',
        url,
        data: response.data,
        statusCode: response.statusCode,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the comprehensive response structure
        final suggestionResponse = UserSuggestionResponse.fromJson(response.data);
        
        AppLogger.success('✅ Current match data fetched successfully');
        return suggestionResponse;
      } else {
        throw Exception('Failed to fetch current match: Invalid response');
      }
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Current match request failed: ${e.message}', e, e.stackTrace);
      
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
      AppLogger.error('❌ Unexpected error in current match: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get next match suggestion
  /// Returns UserSuggestionResponse with comprehensive match data
  Future<UserSuggestionResponse> getNextMatch() async {
    try {
      if (!isAuthenticated) {
        throw Exception('Authentication required');
      }

      final url = '${AppUrls.baseUrl}${AppUrls.aiNextMatch}';

      AppLogger.api('POST', url);
      
      final response = await _dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Log the API response
      AppLogger.api(
        'POST',
        url,
        data: response.data,
        statusCode: response.statusCode,
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the comprehensive response structure
        final suggestionResponse = UserSuggestionResponse.fromJson(response.data);
        
        AppLogger.success('✅ Next match data fetched successfully');
        return suggestionResponse;
      } else {
        throw Exception('Failed to fetch next match: Invalid response');
      }
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Next match request failed: ${e.message}', e, e.stackTrace);
      
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
      AppLogger.error('❌ Unexpected error in next match: $e', e, stackTrace);
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Get backward compatible UserSuggestion (legacy format)
  /// Returns UserSuggestion in the old format for compatibility
  Future<UserSuggestion?> getCurrentMatchLegacy() async {
    try {
      final response = await getCurrentMatch();
      
      // Use backward compatibility to convert new UserData to UserSuggestion
      return UserSuggestion.fromUserData(
        response.data.currentMatch.user,
        response.data.currentMatch.matchScore,
      );
    } catch (e) {
      AppLogger.error('❌ Failed to get legacy match data: $e');
      return null;
    }
  }

  /// Get backward compatible next match (legacy format)
  /// Returns UserSuggestion in the old format for compatibility
  Future<UserSuggestion?> getNextMatchLegacy() async {
    try {
      final response = await getNextMatch();
      
      // Use backward compatibility to convert new UserData to UserSuggestion
      return UserSuggestion.fromUserData(
        response.data.currentMatch.user,
        response.data.currentMatch.matchScore,
      );
    } catch (e) {
      AppLogger.error('❌ Failed to get legacy next match data: $e');
      return null;
    }
  }

  /// Refresh authentication headers
  void refreshHeaders() {
    _dio.options.headers = LocalStorage.getAuthHeaders();
  }

  /// Check if service is ready (authenticated and headers set)
  bool get isReady => isAuthenticated && _dio.options.headers['Authorization'] != null;
}