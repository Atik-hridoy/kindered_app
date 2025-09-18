import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../model/location_model.dart';

class LocationService {
  final Dio _dio;

  LocationService() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: {
      'Authorization': 'Bearer ${LocalStorage.token}',
      'Content-Type': 'application/json',
    },
  ));

  /// Check if user is authenticated
  bool get isAuthenticated => LocalStorage.token.isNotEmpty;

  /// Update user location
  /// Returns UserLocationResponse with updated user data
  Future<UserLocationResponse> updateLocation({
    required List<double> coordinates, // [longitude, latitude]
  }) async {
    try {
      AppLogger.api('PATCH', AppUrls.userLocation, data: {'coordinates': coordinates});
      
      final response = await _dio.patch(
        AppUrls.userLocation,
        data: {
          'coordinates': coordinates,
        },
      );

      // Log the API response
      AppLogger.api(
        'PATCH',
        AppUrls.userLocation,
        data: response.data,
        statusCode: response.statusCode,
      );

      // Parse the response using the model
      final locationResponse = UserLocationResponse.fromJson(response.data);
      
      AppLogger.success('✅ User location updated successfully');
      return locationResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Location update failed: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Location update failed';
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
      // Log general error
      AppLogger.error('❌ Unexpected error in location update: ${e.toString()}');
      throw Exception('Failed to update location: ${e.toString()}');
    }
  }

  /// Get user location (if needed in future)
  Future<UserLocationResponse?> getUserLocation() async {
    try {
      AppLogger.api('GET', '${AppUrls.userLocation}/current');
      
      final response = await _dio.get(
        '${AppUrls.userLocation}/current',
      );

      // Log the API response
      AppLogger.api(
        'GET',
        '${AppUrls.userLocation}/current',
        data: response.data,
        statusCode: response.statusCode,
      );

      // Parse the response using the model
      final locationResponse = UserLocationResponse.fromJson(response.data);
      
      AppLogger.success('✅ User location fetched successfully');
      return locationResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Failed to get user location: ${e.message}', e, e.stackTrace);
      return null;
      
    } catch (e) {
      // Log general error
      AppLogger.error('❌ Unexpected error getting location: ${e.toString()}');
      return null;
    }
  }
}