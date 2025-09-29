import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';
import 'package:kindered_app/modules/profile_and_settings/model/display_profile.dart';

/// Service class for managing profile-related API operations
/// Handles profile updates, data fetching, and match information
/// 
/// Features:
/// - Token-based authentication
/// - Multipart file upload support
/// - Centralized error handling
/// - Type-safe API responses
class ProfileService {
  final Dio _dio;

  /// Creates a new ProfileService instance with authentication
  /// 
  /// [token] - Bearer token for API authentication
  ProfileService(String token) : _dio = _createDioInstance(token);

  /// Factory method to create configured Dio instance
  static Dio _createDioInstance(String token) {
    final dio = Dio(BaseOptions(
      baseUrl: AppUrls.baseUrl,
      headers: LocalStorage.getAuthHeaders(),
      validateStatus: (status) => status! < 500,
    ));
    
    if (token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }
    
    return dio;
  }

  /// Updates the authentication token for all subsequent requests
  /// 
  /// [newToken] - New bearer token to use for authentication
  void updateToken(String newToken) {
    _dio.options.headers.addAll(LocalStorage.getAuthHeaders());
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
  }

  /// Updates user profile with provided data and optional images
  /// 
  /// [data] - Profile data to update
  /// [images] - Optional list of image files to upload
  /// 
  /// Returns: API response from the server
  /// Throws: Exception with descriptive error message
  Future<Response> updateProfile({
    required Map<String, dynamic> data,
    List<File>? images,
  }) async {
    _validateAuthentication();
    
    try {
      final payload = _preparePayload(data, images);
      final options = _getRequestOptions(images?.isNotEmpty ?? false);
      
      final response = await _dio.patch(
        AppUrls.updateProfile,
        data: payload,
        options: options,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Profile update failed');
    } catch (e) {
      throw Exception('An unexpected error occurred while updating profile');
    }
  }

  /// Fetches current user profile data from the server
  /// 
  /// Returns: API response containing profile data
  /// Throws: Exception with descriptive error message
  Future<Response> getProfile() async {
    try {
      final response = await _dio.get(AppUrls.getProfile);
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch profile data');
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching profile');
    }
  }

  /// Fetches and parses user profile into UserProfile model
  /// 
  /// Returns: Parsed UserProfile object
  /// Throws: Exception if parsing fails or API call fails
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await getProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        return UserProfile.fromJson(response.data);
      }
      
      throw Exception('Failed to create UserProfile from API response');
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches current match data from AI matchmaking service
  /// 
  /// Returns: Parsed CurrentMatchsResponse object
  /// Throws: Exception if API call fails or parsing fails
  Future<CurrentMatchsResponse> getCurrentMatch() async {
    try {
      final response = await _dio.get(AppUrls.aiCurrentMatch);
      
      if (response.statusCode == 200 && response.data != null) {
        return CurrentMatchsResponse.fromJson(response.data);
      }
      
      throw Exception('Failed to create CurrentMatchResponse from API response');
    } on DioException catch (e) {
      throw _handleDioError(e, 'Failed to fetch current match data');
    } catch (e) {
      throw Exception('An unexpected error occurred while fetching current match');
    }
  }

  // MARK: - Private Helper Methods

  /// Validates that user is authenticated
  /// 
  /// Throws: Exception if no valid token is found
  void _validateAuthentication() {
    if (LocalStorage.token.isEmpty) {
      throw Exception('No access token found. Please log in again.');
    }
  }

  /// Prepares payload for API request based on whether images are included
  /// 
  /// [data] - Profile data to include
  /// [images] - Optional image files
  /// 
  /// Returns: FormData if images present, Map otherwise
  dynamic _preparePayload(Map<String, dynamic> data, List<File>? images) {
    if (images != null && images.isNotEmpty) {
      return _createMultipartPayload(data, images.first);
    } else {
      return _createJsonPayload(data);
    }
  }

  /// Creates multipart form data payload for image upload
  /// 
  /// [data] - Profile data
  /// [image] - Image file to upload
  /// 
  /// Returns: FormData object with image and profile data
  FormData _createMultipartPayload(Map<String, dynamic> data, File image) {
    final payload = Map<String, dynamic>.from(data);
    
    final filename = image.path.split(Platform.pathSeparator).last;
    final multipartFile = MultipartFile.fromFileSync(
      image.path,
      filename: filename,
    );
    
    payload['image'] = multipartFile;
    return FormData.fromMap(payload);
  }

  /// Creates JSON payload for profile update without images
  /// 
  /// [data] - Profile data
  /// 
  /// Returns: Map with profile data and empty image array
  Map<String, dynamic> _createJsonPayload(Map<String, dynamic> data) {
    final json = Map<String, dynamic>.from(data);
    if (!data.containsKey('image')) {
      json['image'] = <dynamic>[];
    }
    return json;
  }

  /// Creates appropriate request options based on content type
  /// 
  /// [isMultipart] - Whether request contains multipart data
  /// 
  /// Returns: Options object with appropriate headers
  Options _getRequestOptions(bool isMultipart) {
    return Options(
      headers: {
        'Content-Type': isMultipart 
          ? 'multipart/form-data' 
          : Headers.jsonContentType,
      },
    );
  }

  /// Centralized Dio error handling
  /// 
  /// [error] - DioException to handle
  /// [defaultMessage] - Default error message if none found in response
  /// 
  /// Returns: Exception with appropriate error message
  Exception _handleDioError(DioException error, String defaultMessage) {
    final errorMessage = error.response?.data['message'] ??
                         error.response?.data['error'] ??
                         error.message ??
                         defaultMessage;
    
    return Exception(errorMessage);
  }
}