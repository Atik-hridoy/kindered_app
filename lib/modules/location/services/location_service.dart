import 'package:dio/dio.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../model/location_model.dart';

class LocationService {
  final Dio _dio;

  LocationService() : _dio = Dio(BaseOptions(
    baseUrl: AppUrls.baseUrl,
    headers: LocalStorage.getAuthHeaders(),
  )) {
    AppLogger.info('🔧 LocationService initialized');
    AppLogger.info('🌐 Base URL: ${AppUrls.baseUrl}');
    AppLogger.info('🔑 Authentication token: ${LocalStorage.token.isNotEmpty ? 'Present' : 'Missing'}');
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    final isAuth = LocalStorage.token.isNotEmpty;
    AppLogger.info('🔐 Authentication check: ${isAuth ? 'Authenticated' : 'Not authenticated'}');
    if (!isAuth) {
      AppLogger.warning('⚠️ No authentication token found');
    }
    return isAuth;
  }

  /// Update user location
  /// Returns UserLocationResponse with updated user data
  Future<UserLocationResponse> updateLocation({
    required List<double> coordinates, // [longitude, latitude]
  }) async {
    try {
      AppLogger.info('🚀 Starting location update to server...');
      AppLogger.info('📤 Request details:');
      AppLogger.info('   - Method: PATCH');
      AppLogger.info('   - URL: ${AppUrls.baseUrl}${AppUrls.userLocation}');
      AppLogger.info('   - Coordinates: $coordinates');
      AppLogger.info('   - Longitude: ${coordinates[0]}');
      AppLogger.info('   - Latitude: ${coordinates[1]}');
      
      // Validate coordinates
      if (coordinates.length != 2) {
        AppLogger.error('❌ Invalid coordinates format: expected [longitude, latitude], got $coordinates');
        throw Exception('Invalid coordinates format');
      }
      
      if (coordinates[0] == 0.0 && coordinates[1] == 0.0) {
        AppLogger.warning('⚠️ Coordinates are [0.0, 0.0] - this might indicate invalid location');
      }
      
      // Prepare request data
      final requestData = {'coordinates': coordinates};
      AppLogger.info('📋 Request payload: $requestData');
      
      // Log the API call
      AppLogger.api('PATCH', AppUrls.userLocation, data: requestData);
      
      final response = await _dio.patch(
        AppUrls.userLocation,
        data: requestData,
      );

      // Log the API response
      AppLogger.api(
        'PATCH',
        AppUrls.userLocation,
        data: response.data,
        statusCode: response.statusCode,
      );
      
      AppLogger.info('📡 Server response received:');
      AppLogger.info('   - Status Code: ${response.statusCode}');
      AppLogger.info('   - Status Message: ${response.statusMessage}');
      AppLogger.info('   - Headers: ${response.headers}');
      AppLogger.info('   - Response Data: ${response.data}');

      // Parse the response using the model
      final locationResponse = UserLocationResponse.fromJson(response.data);
      
      AppLogger.success('✅ User location updated successfully');
      AppLogger.info('📊 Parsed response details:');
      AppLogger.info('   - Success: ${locationResponse.success}');
      AppLogger.info('   - Message: ${locationResponse.message}');
      AppLogger.info('   - Status Code: ${locationResponse.statusCode}');
      if (locationResponse.data != null) {
        AppLogger.info('   - User Data: Available');
      } else {
        AppLogger.info('   - User Data: Null');
      }
      
      return locationResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Location update failed: ${e.message}', e, e.stackTrace);
      
      AppLogger.error('📋 DioException details:');
      AppLogger.error('   - Type: ${e.type}');
      AppLogger.error('   - Message: ${e.message}');
      AppLogger.error('   - Stack Trace: ${e.stackTrace}');
      
      if (e.response != null) {
        AppLogger.error('📡 Server error response:');
        AppLogger.error('   - Status Code: ${e.response?.statusCode}');
        AppLogger.error('   - Status Message: ${e.response?.statusMessage}');
        AppLogger.error('   - Headers: ${e.response?.headers}');
        AppLogger.error('   - Response Data: ${e.response?.data}');
      }
      
      AppLogger.error('📤 Request details:');
      AppLogger.error('   - Method: ${e.requestOptions.method}');
      AppLogger.error('   - URL: ${e.requestOptions.uri}');
      AppLogger.error('   - Headers: ${e.requestOptions.headers}');
      AppLogger.error('   - Data: ${e.requestOptions.data}');
      
      String errorMessage = 'Location update failed';
      if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
          AppLogger.error('📋 Extracted error message from response: $errorMessage');
        } else if (e.response?.data is String) {
          errorMessage = e.response?.data;
          AppLogger.error('📋 Extracted error message from string response: $errorMessage');
        }
      } else if (e.message != null) {
        errorMessage = e.message!;
        AppLogger.error('📋 Extracted error message from DioException: $errorMessage');
      }
      
      throw Exception(errorMessage);
      
    } catch (e) {
      // Log general error
      AppLogger.error('❌ Unexpected error in location update: ${e.toString()}');
      AppLogger.error('📋 Error type: ${e.runtimeType}');
      if (e is StackTrace) {
        AppLogger.error('📋 Stack trace: $e');
      }
      throw Exception('Failed to update location: ${e.toString()}');
    }
  }

  /// Get user location (if needed in future)
  Future<UserLocationResponse?> getUserLocation() async {
    try {
      AppLogger.info('🔍 Fetching current user location from server...');
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
      
      AppLogger.info('📡 Server response received:');
      AppLogger.info('   - Status Code: ${response.statusCode}');
      AppLogger.info('   - Status Message: ${response.statusMessage}');
      AppLogger.info('   - Response Data: ${response.data}');

      // Parse the response using the model
      final locationResponse = UserLocationResponse.fromJson(response.data);
      
      AppLogger.success('✅ User location fetched successfully');
      AppLogger.info('📊 Parsed response details:');
      AppLogger.info('   - Success: ${locationResponse.success}');
      AppLogger.info('   - Message: ${locationResponse.message}');
      AppLogger.info('   - Status Code: ${locationResponse.statusCode}');
      if (locationResponse.data != null) {
        AppLogger.info('   - User Data: Available');
      } else {
        AppLogger.info('   - User Data: Null');
      }
      
      return locationResponse;
      
    } on DioException catch (e) {
      // Log Dio error with details
      AppLogger.error('❌ Failed to get user location: ${e.message}', e, e.stackTrace);
      
      if (e.response != null) {
        AppLogger.error('📡 Server error response:');
        AppLogger.error('   - Status Code: ${e.response?.statusCode}');
        AppLogger.error('   - Status Message: ${e.response?.statusMessage}');
        AppLogger.error('   - Response Data: ${e.response?.data}');
      }
      
      return null;
      
    } catch (e) {
      // Log general error
      AppLogger.error('❌ Unexpected error getting location: ${e.toString()}');
      AppLogger.error('📋 Error type: ${e.runtimeType}');
      return null;
    }
  }
}