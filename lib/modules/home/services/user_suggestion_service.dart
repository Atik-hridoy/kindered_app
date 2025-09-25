import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
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
        throw Exception('Authentication required');
      }

      final url = '${AppUrls.baseUrl}${AppUrls.aiCurrentMatch}';

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Parse the new comprehensive response structure
        final suggestionResponse = UserSuggestionResponse.fromJson(response.data);
        
        // Use backward compatibility to convert new UserData to UserSuggestion
        return UserSuggestion.fromUserData(
          suggestionResponse.data.currentMatch.user,
          suggestionResponse.data.currentMatch.matchScore,
        );
      } else {
        return null;
      }
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get next match suggestion
  Future<UserSuggestion?> getNextMatch() async {
    try {
      final response = await _dio.get(AppUrls.aiNextMatch);

      if (response.statusCode == 200 && response.data != null) {
        // Parse the new comprehensive response structure
        final suggestionResponse = UserSuggestionResponse.fromJson(response.data);
        
        // Use backward compatibility to convert new UserData to UserSuggestion
        return UserSuggestion.fromUserData(
          suggestionResponse.data.currentMatch.user,
          suggestionResponse.data.currentMatch.matchScore,
        );
      } else {
        return null;
      }
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}
