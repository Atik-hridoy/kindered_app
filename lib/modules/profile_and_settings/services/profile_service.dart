import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart'; 
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          ),
        );

  /// Update Profile POST request
  /// Sends profile data to the complete-profile endpoint
  /// If [images] are provided, the request will be sent as multipart/form-data
  /// with the images attached under the key 'image'.
  Future<Response> updateProfile({
    required Map<String, dynamic> data,
    List<File>? images,
  }) async {
    try {
      AppLogger.info('🔄 [PROFILE SERVICE] Starting profile update request...');
      AppLogger.info('📋 [PROFILE SERVICE] Endpoint: ${AppUrls.completeProfile}');
      
      // Build payload
      Response response;
      if (images != null && images.isNotEmpty) {
        // Prepare multipart form data
        final payload = Map<String, dynamic>.from(data);
        // Attach images list
        final files = <MultipartFile>[];
        for (final file in images) {
          try {
            final filename = file.path.split(Platform.pathSeparator).last;
            files.add(await MultipartFile.fromFile(file.path, filename: filename));
            AppLogger.info('📸 [PROFILE SERVICE] Added image: $filename');
          } catch (e, st) {
            AppLogger.warning('⚠️ [PROFILE SERVICE] Skipping an image that could not be read: ${file.path}', e, st as StackTrace?);
          }
        }
        // Backend expects key `image` to be an array
        payload['image'] = files;

        final formData = FormData.fromMap(payload);
        AppLogger.api('POST', AppUrls.completeProfile, data: '[multipart form with ${files.length} photos]');
        
        response = await _dio.post(
          AppUrls.completeProfile,
          data: formData,
        );
      } else {
        // JSON payload - ensure `image` key exists as an empty array if backend requires it
        final json = {
          ...data,
          'image': data.containsKey('image') ? data['image'] : <dynamic>[],
        };
        AppLogger.api('POST', AppUrls.completeProfile, data: json);
        
        response = await _dio.post(
          AppUrls.completeProfile,
          data: json,
          options: Options(contentType: Headers.jsonContentType),
        );
      }

      // Log the API response
      AppLogger.api(
        'POST',
        AppUrls.completeProfile,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ [PROFILE SERVICE] Profile update successful');
      AppLogger.info('📊 [PROFILE SERVICE] Response status: ${response.statusCode}');
      AppLogger.info('📝 [PROFILE SERVICE] Response data: ${response.data}');
      
      return response;
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ [PROFILE SERVICE] Profile update failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Profile update failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
        } else {
          errorMessage = e.response?.data.toString() ?? errorMessage;
        }
      } else if (e.message != null) {
        errorMessage = e.message ?? errorMessage;
      }
      
      AppLogger.error('❌ [PROFILE SERVICE] Error message: $errorMessage');
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.error('❌ [PROFILE SERVICE] Unexpected error during profile update: $e');
      throw Exception('An unexpected error occurred while updating profile');
    }
  }

  /// Get current profile data
  Future<Response> getProfile() async {
    try {
      AppLogger.info('🔄 [PROFILE SERVICE] Fetching current profile data...');
      AppLogger.info('📋 [PROFILE SERVICE] Endpoint: ${AppUrls.getProfile}');
      
      final response = await _dio.get(
        AppUrls.getProfile,
      );

      AppLogger.api('GET', AppUrls.getProfile, statusCode: response.statusCode);
      AppLogger.info('📊 [PROFILE SERVICE] Response status: ${response.statusCode}');
      AppLogger.info('📝 [PROFILE SERVICE] Response data: ${response.data}');
      AppLogger.success('✅ [PROFILE SERVICE] Profile data fetched successfully');
      
      return response;
    } on DioException catch (e) {
      AppLogger.error('❌ [PROFILE SERVICE] Failed to fetch profile data: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Failed to fetch profile data';
      if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
        } else {
          errorMessage = e.response?.data.toString() ?? errorMessage;
        }
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.error('❌ [PROFILE SERVICE] Unexpected error fetching profile: $e');
      throw Exception('An unexpected error occurred while fetching profile');
    }
  }

  /// Get current profile data as UserProfile object
  Future<UserProfile> getUserProfile() async {
    try {
      AppLogger.info('🔄 [PROFILE SERVICE] Fetching UserProfile object...');
      
      final response = await getProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        final userProfile = UserProfile.fromJson(response.data);
        AppLogger.success('✅ [PROFILE SERVICE] UserProfile object created successfully');
        return userProfile;
      } else {
        throw Exception('Failed to create UserProfile from API response');
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE SERVICE] Error creating UserProfile: $e');
      rethrow;
    }
  }
}
