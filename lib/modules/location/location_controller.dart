import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'services/location_service.dart';
import 'model/location_model.dart';

class LocationController extends GetxController {
  // Location Service
  late LocationService _locationService;
  
  // Observables
  final RxBool isLoading = false.obs;
  final RxBool isGettingLocation = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserLocationResponse?> locationResponse = Rx<UserLocationResponse?>(null);
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxBool locationPermissionGranted = false.obs;
  final RxBool locationServiceEnabled = false.obs;
  
  // Location coordinates
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize location service
    _locationService = LocationService();
    
    // Check location service status
    _checkLocationServices();
  }
  
  /// Check if location services are enabled
  Future<void> _checkLocationServices() async {
    try {
      AppLogger.info('🔍 Checking location services status...');
      locationServiceEnabled.value = await Geolocator.isLocationServiceEnabled();
      
      AppLogger.info('📍 Location services enabled: ${locationServiceEnabled.value}');
      
      if (!locationServiceEnabled.value) {
        AppLogger.warning('⚠️ Location services are disabled');
        errorMessage.value = 'Location services are disabled. Please enable location services to continue.';
      } else {
        AppLogger.success('✅ Location services are enabled');
      }
    } catch (e) {
      AppLogger.error('❌ Error checking location services', e);
      errorMessage.value = 'Failed to check location services: ${e.toString()}';
    }
  }
  
  /// Request location permission
  Future<bool> _requestLocationPermission() async {
    try {
      AppLogger.info('🔐 Requesting location permission...');
      isGettingLocation.value = true;
      errorMessage.value = '';
      
      LocationPermission permission = await Geolocator.checkPermission();
      AppLogger.info('📋 Current permission status: $permission');
      
      if (permission == LocationPermission.denied) {
        AppLogger.info('🙏 Requesting location permission...');
        permission = await Geolocator.requestPermission();
        AppLogger.info('📋 Permission after request: $permission');
      }
      
      if (permission == LocationPermission.deniedForever) {
        AppLogger.error('❌ Location permissions permanently denied');
        errorMessage.value = 'Location permissions are permanently denied. Please enable location permissions in app settings.';
        locationPermissionGranted.value = false;
        return false;
      }
      
      if (permission == LocationPermission.denied) {
        AppLogger.warning('⚠️ Location permissions denied');
        errorMessage.value = 'Location permissions are denied. Please enable location permissions to continue.';
        locationPermissionGranted.value = false;
        return false;
      }
      
      AppLogger.success('✅ Location permissions granted: $permission');
      locationPermissionGranted.value = true;
      return true;
      
    } catch (e) {
      AppLogger.error('❌ Error requesting location permission', e);
      errorMessage.value = 'Failed to request location permission: ${e.toString()}';
      locationPermissionGranted.value = false;
      return false;
    } finally {
      isGettingLocation.value = false;
    }
  }
  
  /// Get current location
  Future<void> getCurrentLocation() async {
    try {
      AppLogger.info('🌍 Getting current location...');
      isGettingLocation.value = true;
      errorMessage.value = '';
      
      // Check if location services are enabled
      if (!locationServiceEnabled.value) {
        AppLogger.info('🔍 Location services not enabled, checking status...');
        await _checkLocationServices();
        if (!locationServiceEnabled.value) {
          AppLogger.warning('⚠️ Location services still disabled, aborting location fetch');
          return;
        }
      }
      
      // Request permission
      AppLogger.info('🔐 Checking location permissions...');
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        AppLogger.warning('⚠️ Location permissions not granted, aborting location fetch');
        return;
      }
      
      // Get current position
      AppLogger.info('📡 Fetching current position with high accuracy...');
      currentPosition.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Update coordinates
      latitude.value = currentPosition.value!.latitude;
      longitude.value = currentPosition.value!.longitude;
      
      AppLogger.success('✅ Current location obtained successfully');
      AppLogger.info('📍 Coordinates: ${latitude.value.toStringAsFixed(6)}, ${longitude.value.toStringAsFixed(6)}');
      AppLogger.info('📊 Position details:');
      AppLogger.info('   - Latitude: ${currentPosition.value!.latitude}');
      AppLogger.info('   - Longitude: ${currentPosition.value!.longitude}');
      AppLogger.info('   - Accuracy: ${currentPosition.value!.accuracy}m');
      AppLogger.info('   - Altitude: ${currentPosition.value!.altitude}m');
      AppLogger.info('   - Speed: ${currentPosition.value!.speed}m/s');
      AppLogger.info('   - Timestamp: ${currentPosition.value!.timestamp}');
      
    } catch (e) {
      AppLogger.error('❌ Error getting current location', e);
      errorMessage.value = 'Failed to get current location: ${e.toString()}';
    } finally {
      isGettingLocation.value = false;
    }
  }
  
  /// Update user location to server
  Future<void> updateUserLocation() async {
    AppLogger.info('🚀 Starting location update process...');
    
    // Check authentication
    if (!_locationService.isAuthenticated) {
      AppLogger.error('❌ User not authenticated for location update');
      errorMessage.value = 'Please log in to update your location';
      return;
    }
    
    AppLogger.info('✅ User authenticated, proceeding with location update');
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Get current location if not already available
      if (currentPosition.value == null) {
        AppLogger.info('📍 No current position available, fetching location...');
        await getCurrentLocation();
        
        if (currentPosition.value == null) {
          AppLogger.error('❌ Failed to get current position');
          errorMessage.value = 'Failed to get current location. Please try again.';
          return;
        }
      }
      
      // Prepare coordinates [longitude, latitude]
      final coordinates = [longitude.value, latitude.value];
      
      AppLogger.info('📤 Preparing to send location data to server:');
      AppLogger.info('   - Longitude: ${longitude.value.toStringAsFixed(6)}');
      AppLogger.info('   - Latitude: ${latitude.value.toStringAsFixed(6)}');
      AppLogger.info('   - Coordinates format: [longitude, latitude]');
      AppLogger.info('   - Full coordinates array: $coordinates');
      
      // Check if coordinates are valid
      if (coordinates[0] == 0.0 && coordinates[1] == 0.0) {
        AppLogger.warning('⚠️ Coordinates are [0.0, 0.0] - this might indicate invalid location');
      }
      
      AppLogger.info('🌐 Calling location service to update server...');
      
      // Update location to server
      final response = await _locationService.updateLocation(coordinates: coordinates);
      locationResponse.value = response;
      
      AppLogger.success('✅ Location updated to server successfully');
      AppLogger.info('📊 Server response details:');
      AppLogger.info('   - Success: ${response.success}');
      AppLogger.info('   - Message: ${response.message}');
      AppLogger.info('   - Status Code: ${response.statusCode}');
      if (response.data != null) {
        AppLogger.info('   - Data: User data received');
      }
      
      // Navigate to next screen after successful location update
      AppLogger.info('🎯 Navigation to home-suggestion screen...');
      Get.offAllNamed('/home-suggestion');
      
    } on DioException catch (e) {
      // Handle network errors specifically
      AppLogger.error('❌ Network error during location update', e);
      
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
        AppLogger.error('🌐 Connection/timeout error: ${e.message}');
      } else {
        errorMessage.value = 'Failed to update location: ${e.message ?? 'Unknown error'}';
        AppLogger.error('📡 Other Dio error: ${e.message}');
      }
      
      // Log detailed error information
      if (e.response != null) {
        AppLogger.error('📋 Server response details:');
        AppLogger.error('   - Status Code: ${e.response?.statusCode}');
        AppLogger.error('   - Status Message: ${e.response?.statusMessage}');
        AppLogger.error('   - Headers: ${e.response?.headers}');
        AppLogger.error('   - Data: ${e.response?.data}');
      }
      
    } catch (e) {
      AppLogger.error('❌ General error during location update: ${e.toString()}');
      errorMessage.value = 'Failed to update location: ${e.toString()}';
    } finally {
      isLoading.value = false;
      AppLogger.info('🏁 Location update process completed');
    }
  }
  
  /// Open app settings for location permissions
  Future<void> openAppSettings() async {
    try {
      AppLogger.info('🔧 Opening app settings for location permissions...');
      await Geolocator.openAppSettings();
      AppLogger.success('✅ App settings opened successfully');
    } catch (e) {
      AppLogger.error('❌ Error opening app settings', e);
      errorMessage.value = 'Failed to open app settings: ${e.toString()}';
    }
  }
  
  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      AppLogger.info('🔧 Opening device location settings...');
      await Geolocator.openLocationSettings();
      AppLogger.success('✅ Location settings opened successfully');
    } catch (e) {
      AppLogger.error('❌ Error opening location settings', e);
      errorMessage.value = 'Failed to open location settings: ${e.toString()}';
    }
  }
  
  /// Clear error message
  void clearError() {
    AppLogger.info('🧹 Clearing error message...');
    errorMessage.value = '';
  }
  
  /// Retry location update
  Future<void> retryLocationUpdate() async {
    AppLogger.info('🔄 Retrying location update...');
    clearError();
    await updateUserLocation();
  }
  
  /// Check if can proceed with location update
  bool get canUpdateLocation {
    final canUpdate = locationServiceEnabled.value && 
                    locationPermissionGranted.value && 
                    currentPosition.value != null;
    
    AppLogger.info('🔍 Location update capability check:');
    AppLogger.info('   - Location Service Enabled: ${locationServiceEnabled.value}');
    AppLogger.info('   - Permission Granted: ${locationPermissionGranted.value}');
    AppLogger.info('   - Current Position Available: ${currentPosition.value != null}');
    AppLogger.info('   - Can Update Location: $canUpdate');
    
    return canUpdate;
  }
  
  /// Get formatted location string
  String get formattedLocation {
    final location = currentPosition.value != null 
        ? '${latitude.value.toStringAsFixed(4)}, ${longitude.value.toStringAsFixed(4)}'
        : 'Location not available';
    
    AppLogger.info('📍 Formatted location: $location');
    return location;
  }
}
