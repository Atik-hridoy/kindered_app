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
      locationServiceEnabled.value = await Geolocator.isLocationServiceEnabled();
      
      if (!locationServiceEnabled.value) {
        errorMessage.value = 'Location services are disabled. Please enable location services to continue.';
      }
    } catch (e) {
      AppLogger.error('Error checking location services', e);
      errorMessage.value = 'Failed to check location services: ${e.toString()}';
    }
  }
  
  /// Request location permission
  Future<bool> _requestLocationPermission() async {
    try {
      isGettingLocation.value = true;
      errorMessage.value = '';
      
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.deniedForever) {
        errorMessage.value = 'Location permissions are permanently denied. Please enable location permissions in app settings.';
        locationPermissionGranted.value = false;
        return false;
      }
      
      if (permission == LocationPermission.denied) {
        errorMessage.value = 'Location permissions are denied. Please enable location permissions to continue.';
        locationPermissionGranted.value = false;
        return false;
      }
      
      locationPermissionGranted.value = true;
      return true;
      
    } catch (e) {
      AppLogger.error('Error requesting location permission', e);
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
      isGettingLocation.value = true;
      errorMessage.value = '';
      
      // Check if location services are enabled
      if (!locationServiceEnabled.value) {
        await _checkLocationServices();
        if (!locationServiceEnabled.value) {
          return;
        }
      }
      
      // Request permission
      final hasPermission = await _requestLocationPermission();
      if (!hasPermission) {
        return;
      }
      
      // Get current position
      currentPosition.value = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Update coordinates
      latitude.value = currentPosition.value!.latitude;
      longitude.value = currentPosition.value!.longitude;
      
      AppLogger.success('✅ Current location obtained: ${latitude.value}, ${longitude.value}');
      
    } catch (e) {
      AppLogger.error('Error getting current location', e);
      errorMessage.value = 'Failed to get current location: ${e.toString()}';
    } finally {
      isGettingLocation.value = false;
    }
  }
  
  /// Update user location to server
  Future<void> updateUserLocation() async {
    if (!_locationService.isAuthenticated) {
      errorMessage.value = 'Please log in to update your location';
      return;
    }
    
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Get current location if not already available
      if (currentPosition.value == null) {
        await getCurrentLocation();
        
        if (currentPosition.value == null) {
          errorMessage.value = 'Failed to get current location. Please try again.';
          return;
        }
      }
      
      // Prepare coordinates [longitude, latitude]
      final coordinates = [longitude.value, latitude.value];
      
      // Update location to server
      final response = await _locationService.updateLocation(coordinates: coordinates);
      locationResponse.value = response;
      
      AppLogger.success('✅ Location updated to server successfully');
      
      // Navigate to next screen after successful location update
      Get.offAllNamed('/home-suggestion');
      
    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      } else {
        errorMessage.value = 'Failed to update location: ${e.message ?? 'Unknown error'}';
      }
      AppLogger.error('Network error updating location', e);
    } catch (e) {
      errorMessage.value = 'Failed to update location: ${e.toString()}';
      AppLogger.error('Error updating location', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Open app settings for location permissions
  Future<void> openAppSettings() async {
    try {
      await Geolocator.openAppSettings();
    } catch (e) {
      AppLogger.error('Error opening app settings', e);
      errorMessage.value = 'Failed to open app settings: ${e.toString()}';
    }
  }
  
  /// Open location settings
  Future<void> openLocationSettings() async {
    try {
      await Geolocator.openLocationSettings();
    } catch (e) {
      AppLogger.error('Error opening location settings', e);
      errorMessage.value = 'Failed to open location settings: ${e.toString()}';
    }
  }
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
  
  /// Retry location update
  Future<void> retryLocationUpdate() async {
    clearError();
    await updateUserLocation();
  }
  
  /// Check if can proceed with location update
  bool get canUpdateLocation => 
      locationServiceEnabled.value && 
      locationPermissionGranted.value && 
      currentPosition.value != null;
  
  /// Get formatted location string
  String get formattedLocation => 
      currentPosition.value != null 
          ? '${latitude.value.toStringAsFixed(4)}, ${longitude.value.toStringAsFixed(4)}'
          : 'Location not available';
}
