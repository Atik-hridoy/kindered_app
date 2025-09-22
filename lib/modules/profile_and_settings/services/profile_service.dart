import 'dart:io';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart'; 
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileService {
  final Dio _dio;

  ProfileService(String token)
      : _dio = Dio(
          BaseOptions(
            baseUrl: AppUrls.baseUrl,
            headers: LocalStorage.getAuthHeaders(),
            validateStatus: (status) {
              return status! < 500; 
            }
          ),
        ) {
    // Ensure the token is set correctly
    if (token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  /// Update Dio headers with new token
  void updateToken(String newToken) {
    _dio.options.headers.addAll(LocalStorage.getAuthHeaders());
    // Ensure the specific token is set
    _dio.options.headers['Authorization'] = 'Bearer $newToken';
    AppLogger.info('🔐 ProfileService token updated');
  }

  Future<Response> updateProfile({
    required Map<String, dynamic> data,
    List<File>? images,
  }) async {
    try {
      AppLogger.info('🔄 [PROFILE SERVICE] Starting profile update request...');
      AppLogger.info('📋 [PROFILE SERVICE] Endpoint: ${AppUrls.updateProfile}');
      AppLogger.info('🔐 [PROFILE SERVICE] Using Bearer authorization');
      
      if (LocalStorage.token.isEmpty) {
        throw Exception('No access token found. Please log in again.');
      }
 
      Response response;
      if (images != null && images.isNotEmpty) {
    
        final payload = Map<String, dynamic>.from(data);

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
    
        payload['image'] = files;

        final formData = FormData.fromMap(payload);
        AppLogger.api('PATCH', AppUrls.updateProfile, data: '[multipart form with ${files.length} photos]');
        
        response = await _dio.patch(
          AppUrls.updateProfile,
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
        );
      } else {
   
        final json = {
          ...data,
          'image': data.containsKey('image') ? data['image'] : <dynamic>[],
        };
        AppLogger.api('PATCH', AppUrls.updateProfile, data: json);
        
        response = await _dio.patch(
          AppUrls.updateProfile,
          data: json,
          options: Options(
            headers: {
              'Content-Type': Headers.jsonContentType,
            },
          ),
        );
      }

      AppLogger.api(
        'PATCH',
        AppUrls.updateProfile,
        data: response.data,
        statusCode: response.statusCode,
      );

      AppLogger.success('✅ [PROFILE SERVICE] Profile update successful');
      AppLogger.info('📊 [PROFILE SERVICE] Response status: ${response.statusCode}');
      AppLogger.info('📝 [PROFILE SERVICE] Response data: ${response.data}');
      
      return response;
    } on DioException catch (e) {
 
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
      
      // Only log success if the response was actually successful
      if (response.statusCode == 200) {
        AppLogger.success('✅ [PROFILE SERVICE] Profile data fetched successfully');
      }
      
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
