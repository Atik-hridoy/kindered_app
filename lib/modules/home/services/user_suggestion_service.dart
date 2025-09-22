import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/home/models/user_suggestion_model.dart';

class UserSuggestionService {
  final Dio _dio;

  UserSuggestionService(this._dio);

  /// Get authentication token
  String? get _authToken => LocalStorage.token.isNotEmpty ? LocalStorage.token : null;

  /// Check if user is authenticated
  bool get isAuthenticated => _authToken != null && _authToken!.isNotEmpty;

  /// Get current match suggestion for photo card
  Future<UserSuggestion?> getCurrentMatch() async {
    try {
      if (!isAuthenticated) {
        AppLogger.warning('⚠️ [SUGGESTION SERVICE] No authentication token found');
        throw Exception('Authentication required');
      }

      final url = '${AppUrls.baseUrl}${AppUrls.aiCurrentMatch}';
      AppLogger.info('📤 [SUGGESTION SERVICE] Fetching current match from: $url');

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      AppLogger.info('📡 [SUGGESTION SERVICE] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        AppLogger.info('✅ [SUGGESTION SERVICE] Successfully fetched current match');
        AppLogger.info('📋 [SUGGESTION SERVICE] Response data: ${response.data}');
        
        // Parse the response - expecting photo card details
        final userData = response.data['data'] ?? response.data;
        return UserSuggestion.fromJson(userData);
      } else {
        AppLogger.warning('⚠️ [SUGGESTION SERVICE] Unexpected response format');
        return null;
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [SUGGESTION SERVICE] DioException: ${e.message}');
      AppLogger.error('❌ [SUGGESTION SERVICE] Response: ${e.response?.data}');
      rethrow;
    } catch (e) {
      AppLogger.error('❌ [SUGGESTION SERVICE] Error fetching current match: $e');
      rethrow;
    }
  }

  /// Get next match suggestion
  Future<UserSuggestion?> getNextMatch() async {
    try {
      AppLogger.info('🔄 [SUGGESTION SERVICE] Fetching next match...');
      AppLogger.info('📋 [SUGGESTION SERVICE] Endpoint: ${AppUrls.aiNextMatch}');
      
      final response = await _dio.get(
        AppUrls.aiNextMatch,
      );

      AppLogger.api('GET', AppUrls.aiNextMatch, statusCode: response.statusCode);
      AppLogger.info('📊 [SUGGESTION SERVICE] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.data != null) {
        final matchData = response.data['match'] ?? response.data;
        
        if (matchData != null) {
          final suggestion = UserSuggestion.fromJson(matchData);
          AppLogger.success('✅ [SUGGESTION SERVICE] Next match fetched successfully');
          return suggestion;
        } else {
          AppLogger.warning('⚠️ [SUGGESTION SERVICE] No match found in response');
          return null;
        }
      } else {
        AppLogger.warning('⚠️ [SUGGESTION SERVICE] No match found or invalid response');
        return null;
      }
    } catch (e) {
      AppLogger.error('❌ [SUGGESTION SERVICE] Failed to fetch next match: $e');
      return null;
    }
  }
}
