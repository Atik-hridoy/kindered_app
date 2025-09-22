import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/services/profile_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileViewController extends GetxController {
  // Profile service for API calls
  late ProfileService _profileService;
  
  // Loading state
  var isLoading = false.obs;
  
  // Profile model
  var userProfile = Rx<UserProfile?>(null);
  
  // Computed getters for profile data
  String get name {
    // Get the actual first name from the reactive userProfile
    final firstName = userProfile.value?.firstName ?? '';
    final lastName = userProfile.value?.lastName ?? '';
    
    // TEMPORARY TEST DATA - Remove when API returns correct data
    final testFirstName = 'ashik';
    
    // Use test data if API returns empty, otherwise use API data
    final displayName = firstName.isNotEmpty ? firstName : testFirstName;
    
    AppLogger.info('👤 [PROFILE VIEW] Dynamic name getter called: "$displayName" (API firstName: "$firstName", lastName: "$lastName", using test: ${firstName.isEmpty ? 'YES' : 'NO'}, userProfile.value: ${userProfile.value != null ? 'EXISTS' : 'NULL'})');
    return displayName;
  }
  
  String get age => userProfile.value?.age?.toString() ?? '';
  String get profilePhoto => _getProfilePhoto();
  int get profileCompletion => userProfile.value?.profileCompletionPercentage ?? 0;
  
  @override
  void onInit() {
    super.onInit();
    _initializeProfileService();
    _loadProfileData();
  }
  
  void _initializeProfileService() {
    try {
      if (LocalStorage.token.isNotEmpty) {
        AppLogger.info('🔐 [PROFILE VIEW] Initializing ProfileService with token (len=${LocalStorage.token.length})');
        _profileService = ProfileService(LocalStorage.token);
      } else {
        AppLogger.warning('❌ [PROFILE VIEW] Missing bearer token. Cannot initialize ProfileService');
        Get.snackbar(
          'Authentication Required',
          'Please sign in to view your profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE VIEW] Error initializing ProfileService: $e');
    }
  }
  
  void _loadProfileData() {
    isLoading.value = true;
    try {
      AppLogger.info('🔄 [PROFILE VIEW] Loading profile data...');
      
      // Load data from API
      fetchProfileData().then((_) {
        AppLogger.info('✅ [PROFILE VIEW] Data loaded: $name, $age, $profileCompletion%');
      }).catchError((error) {
        AppLogger.warning('⚠️ [PROFILE VIEW] Failed to load from API, using defaults: $error');
        _setDefaultValues();
      });
    } catch (e) {
      AppLogger.error('❌ [PROFILE VIEW] Error loading profile data: $e');
      _setDefaultValues();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Fetch profile data from API
  Future<void> fetchProfileData() async {
    if (LocalStorage.token.isEmpty) {
      AppLogger.warning('❌ [PROFILE VIEW] No access token found');
      return;
    }
    
    try {
      AppLogger.info('🔄 [PROFILE VIEW] Fetching profile data from API...');
      
      // Fetch profile data as UserProfile object
      final userProfileData = await _profileService.getUserProfile();
      
      AppLogger.info('📋 [PROFILE VIEW] UserProfile object received:');
      AppLogger.info('   👤 Name: ${userProfileData.firstName} ${userProfileData.lastName}');
      AppLogger.info('   🎂 Age: ${userProfileData.age}');
      AppLogger.info('   📊 Profile Completion: ${userProfileData.profileCompletionPercentage}%');
      AppLogger.info('   📸 Images count: ${userProfileData.image.length}');
      
      if (userProfileData.image.isNotEmpty) {
        AppLogger.info('   🖼️  First image (headshot): ${userProfileData.image.first}');
      } else {
        AppLogger.info('   🖼️  No images found, will use fallback avatar');
      }
      
      // Set the UserProfile object directly
      AppLogger.info('🔄 [PROFILE VIEW] Updating userProfile reactive variable...');
      userProfile.value = userProfileData;
      AppLogger.info('✅ [PROFILE VIEW] userProfile updated. New value: ${userProfile.value?.firstName ?? 'NULL'} ${userProfile.value?.lastName ?? 'NULL'}');
      
      // Log the name getter result immediately after update
      AppLogger.info('🔄 [PROFILE VIEW] Name getter after update: "${name}"');
      
      AppLogger.success('✅ [PROFILE VIEW] Profile data loaded successfully');
    } on DioException catch (e) {
      AppLogger.error('❌ [PROFILE VIEW] Dio error: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Failed to fetch profile data';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please sign in again.';
        _handleAuthError();
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      AppLogger.error('❌ [PROFILE VIEW] Unexpected error: $e');
      throw Exception('An unexpected error occurred while fetching profile data');
    }
  }
  
  
  
  void _setDefaultValues() {
    // Create a default UserProfile object
    userProfile.value = UserProfile(
      id: '',
      role: '',
      email: '',
      age: 28,
      gender: '',
      firstName: 'John Doe',
      lastName: '',
      aboutMe: '',
      religion: '',
      zodiacSign: '',
      status: '',
      isVerified: false,
      profileCompletionPercentage: 0,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      habits: null,
      interests: null,
      lifestyle: null,
      likeToMeet: [],
      personalTraitsInspire: [],
      image: [],
      phone: '',
      relationType: '',
      location: null,
    );
    AppLogger.info('📋 [PROFILE VIEW] Default values set using UserProfile model');
  }
  
  /// Handle authentication errors (401)
  void _handleAuthError() {
    try {
      AppLogger.warning('🔐 [PROFILE VIEW] Handling authentication error...');
      
      // Clear local storage
      LocalStorage.token = '';
      LocalStorage.isLogIn = false;
      LocalStorage.userId = '';
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      
      AppLogger.info('✅ [PROFILE VIEW] User redirected to login screen');
    } catch (e) {
      AppLogger.error('❌ [PROFILE VIEW] Error handling auth error: $e');
    }
  }
  
  void refreshProfileData() {
    _loadProfileData();
  }
  
  /// Refresh only the profile photo (useful when returning from edit profile)
  void refreshProfilePhoto() {
    isLoading.value = true;
    fetchProfileData().then((_) {
      isLoading.value = false;
    }).catchError((error) {
      AppLogger.error('❌ [PROFILE VIEW] Error refreshing profile photo: $error');
      isLoading.value = false;
    });
  }
  
  String get profileCompletionText {
    final completion = profileCompletion; // Use the computed getter
    if (completion == 100) {
      return 'Your profile is complete!';
    } else if (completion >= 80) {
      return 'Your profile is $completion% complete!';
    } else if (completion >= 50) {
      return 'Your profile is $completion% complete. Keep going!';
    } else {
      return 'Your profile is $completion% complete. Add more details!';
    }
  }
  
  /// Get profile photo with dynamic fallback
  String _getProfilePhoto() {
    AppLogger.info('🖼️  [PROFILE VIEW] Getting profile photo...');
    
    // If user has actual profile photos, return the first one (headshot)
    if (userProfile.value?.image.isNotEmpty == true) {
      final headshotUrl = userProfile.value!.image.first;
      AppLogger.info('✅ [PROFILE VIEW] Using headshot from API: $headshotUrl');
      return headshotUrl;
    }
    
    // If no photos from API, generate dynamic fallback based on user data
    AppLogger.info('🎨 [PROFILE VIEW] No headshot found, generating dynamic fallback...');
    final fallbackUrl = _generateDynamicFallbackPhoto();
    AppLogger.info('✅ [PROFILE VIEW] Using fallback avatar: $fallbackUrl');
    return fallbackUrl;
  }
  
  /// Generate dynamic fallback profile photo URL
  String _generateDynamicFallbackPhoto() {
    final userName = name.toLowerCase().trim();
    final userAge = age.isNotEmpty ? int.tryParse(age) ?? 28 : 28;
    
    // Use user's name to generate a seed for consistent avatar
    final seed = userName.isNotEmpty ? userName : 'user${userAge}';
    
    // Generate dynamic avatar URL using UI Avatars API
    // This generates consistent avatars based on seed with app's accent color
    return 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(seed)}&background=D4A373&color=fff&size=200&format=png';
  }
}