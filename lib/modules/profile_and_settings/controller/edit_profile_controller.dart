import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/services/profile_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileEditController extends GetxController {

  late final ProfileService _profileService;
  

  final isLoading = RxBool(false);
  final _isInitialized = RxBool(false);
  
  final Rx<UserProfile?> _userProfile = Rx<UserProfile?>(null);
  final _profileCompletion = RxInt(0);
  
  final ImagePicker _imagePicker = ImagePicker();

  bool get isLoadingValue => isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isProfileServiceInitialized => _isInitialized.value;
  UserProfile? get profile => _userProfile.value;
  int get profileCompletion => _profileCompletion.value;
  int get profileCompletionPercentage => profile?.profileCompletionPercentage ?? 0;
  
  String get userFirstName => _userProfile.value?.firstName ?? '';
  String get userLastName => _userProfile.value?.lastName ?? '';
  String get userEmail => _userProfile.value?.email ?? '';
  String get userAge => _userProfile.value?.age?.toString() ?? '';
  String get userGender => _userProfile.value?.gender ?? '';
  String get userAboutMe => _userProfile.value?.aboutMe ?? '';
  String get userReligion => _userProfile.value?.religion ?? '';
  String get userZodiacSign => _userProfile.value?.zodiacSign ?? '';
  
  List<String> get userPhotos => _userProfile.value?.image ?? [];
  List<String> get userTraits => _userProfile.value?.personalTraitsInspire ?? [];
  List<String> get userPreferences => _userProfile.value?.likeToMeet ?? [];
  
  List<String> get userInterests {
    final interests = _userProfile.value?.interests;
    if (interests == null) return [];
    
    return [
      ...interests.hobbies,
      ...interests.creativeOutlets,
      ...interests.fitnessAndSports,
      ...interests.entertainment,
      ...interests.leisureActivities,
      ...interests.musicGenres,
      ...interests.healthAndWellness,
      ...interests.readingAndContent,
    ];
  }
  
  List<String> get userCommunicationStyle => _userProfile.value?.habits?.communicationStyle ?? [];
  String get userWorkout => _userProfile.value?.habits?.workout ?? '';
  List<String> get userEatingStyle => _userProfile.value?.habits?.eatingStyle ?? [];
  String get userSocialMedia => _userProfile.value?.habits?.socialMedia ?? '';
  String get userSmokeOrDrink => _userProfile.value?.habits?.smokeOrDrink ?? '';
  String get userNewExperiences => _userProfile.value?.habits?.newExercise ?? '';

  String get userSleepingStyle => _userProfile.value?.lifestyle?.sleepingStyle ?? '';
  String get userLoveStyle => _userProfile.value?.lifestyle?.loveStyle ?? '';
  String get userWeekend => _userProfile.value?.lifestyle?.weekends ?? '';
  String get userTravelling => _userProfile.value?.lifestyle?.traveling ?? '';
  String get userHomeEnvironment => _userProfile.value?.lifestyle?.homeEnvironment ?? '';
  String get userLivingSpace => _userProfile.value?.lifestyle?.livingSpace ?? '';
  String get userLocation => _userProfile.value?.location != null ? 'Location available' : '';
  String get userRelationType => _userProfile.value?.relationType ?? '';

  Future<void> pickImageFromCamera(int index) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        await _handlePickedImage(pickedFile, index);
      }
    } catch (e) {
      _handleImagePickError(e);
    }
  }

  Future<void> pickImageFromGallery(int index) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        await _handlePickedImage(pickedFile, index);
      }
    } catch (e) {
      _handleImagePickError(e);
    }
  }

  Future<void> _handlePickedImage(XFile pickedFile, int index) async {
    AppLogger.info('📸 [PROFILE CONTROLLER] Image picked: ${pickedFile.path}');
    
    if (!isProfileServiceInitialized) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Profile service not initialized');
      return;
    }
    
    isLoading.value = true;
    try {
      final file = File(pickedFile.path);
      
      final response = await _profileService.updateProfile(
        data: {},
        images: [file],
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadProfileData();
        
        Get.snackbar(
          'Success',
          'Profile photo updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Error uploading image: $e');
      Get.snackbar(
        'Error',
        'Failed to upload photo. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _handleImagePickError(dynamic error) {
    AppLogger.error('❌ [PROFILE CONTROLLER] Error picking image: $error');
    Get.snackbar(
      'Error',
      'Failed to pick photo. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
  
  final List<String> sleepingStyles = [
    'Early bird',
    'Night owl',
    'Flexible',
    'Regular schedule'
  ];

  final List<String> travelingStyles = [
    'Love to travel',
    'Occasional trips',
    'Rarely travel',
    'Never travel',
    'Business travel only',
    'Adventure seeker'
  ];

  final List<String> loveStyles = [
    'Romantic',
    'Practical',
    'Passionate',
    'Playful',
    'Traditional',
    'Modern',
    'Independent',
    'Affectionate'
  ];

  final List<String> weekendStyles = [
    'Active and outdoors',
    'Relaxing at home',
    'Socializing',
    'Mix of everything',
    'Working',
    'Hobbies and projects'
  ];
  
  // Location
  String get location => profile?.location != null ? 'Location available' : '';
  
  // Additional getters for compatibility with existing UI
  String get height => profile?.lifestyle?.sleepingStyle ?? '';
  String get weight => profile?.lifestyle?.loveStyle ?? '';
  String get education => profile?.lifestyle?.weekends ?? '';
  String get jobStatus => profile?.lifestyle?.traveling ?? '';
  String get lookingFor => profile?.relationType ?? '';
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }

  void _initializeController() {
    _initializeProfileService().then((_) {
      if (LocalStorage.token.isNotEmpty && isProfileServiceInitialized) {
        _loadProfileData();
      }
    }).catchError((e) {
      AppLogger.error('❌ Error initializing controller: $e');
    });
  }
  
  Future<void> _initializeProfileService() async {
    
    try {
      // Refresh token from preferences
      final token = await LocalStorage.getString(LocalStorageKeys.token);
      
      if (token.isEmpty) {
        print('DEBUG: No token found - showing error snackbar');
        AppLogger.warning('❌ Missing token. Cannot initialize ProfileService');
        Get.snackbar(
          'Authentication Required',
          'Please sign in to view your profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      LocalStorage.token = token;
      _profileService = ProfileService(token);
      _isInitialized.value = true;
      AppLogger.info('🔐 ProfileService initialized with token (len=${token.length})');
      
    } catch (e) {
      print('DEBUG: Error in _initializeProfileService: $e');
      AppLogger.error('❌ Error initializing ProfileService: $e');
      rethrow;
    }
  }
  
  /// Load profile data from API
  Future<void> _loadProfileData() async {
    
    if (!isProfileServiceInitialized || LocalStorage.token.isEmpty) {
      AppLogger.warning('❌ Profile service not initialized or no token found');
      return;
    }
    
    isLoading.value = true;
    try {
      AppLogger.info('🔄 [PROFILE LOAD] Loading profile data from API...');
      
      // Make API call to get profile data
      final response = await _profileService.getProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        final profileData = response.data;
        
        // Log complete API response in Postman-like format
        AppLogger.info('📋 [PROFILE LOAD] ===== COMPLETE API RESPONSE (POSTMAN STYLE) =====');
        AppLogger.info('📋 Status Code: ${response.statusCode}');
        AppLogger.info('📋 Response Headers: ${response.headers}');
        AppLogger.info('📋 Response Body:');
        AppLogger.info('📋 ${_formatJsonForLogging(profileData)}');
        AppLogger.info('📋 ===== END API RESPONSE =====');
        
        // Map API response to controller variables
        _mapApiDataToController(profileData);
        
        AppLogger.info('✅ [PROFILE LOAD] Profile data loaded successfully');
      } else if (response.statusCode == 401) {
        AppLogger.warning('🔐 [PROFILE LOAD] Authentication failed (401)');
        _handleAuthError();
      } else {
        AppLogger.warning('⚠️ [PROFILE LOAD] Unexpected response: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch profile data (${response.statusCode}). Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [PROFILE LOAD] Dio error: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Failed to fetch profile data';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please sign in again.';
        _handleAuthError();
      } else if (e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('❌ [PROFILE LOAD] Unexpected error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while fetching profile data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Format JSON data for logging in a readable way
  String _formatJsonForLogging(dynamic data) {
    try {
      if (data is Map || data is List) {
        // Convert to JSON string with indentation for readability
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(data);
      } else {
        return data.toString();
      }
    } catch (e) {
      return 'Error formatting JSON: $e\nRaw data: $data';
    }
  }
  
  /// Map API response data to UserProfile model
  void _mapApiDataToController(Map<String, dynamic> data) {
    try {
      AppLogger.info('🔄 [PROFILE MAPPING] Mapping API data to UserProfile model...');
      
      // Extract the actual profile data from the response wrapper
      final profileData = data['data'] as Map<String, dynamic>;
      
      // Create UserProfile from API data
      final userProfileData = UserProfile.fromJson(profileData);
      
      // Debug logging for each section
      print('\n=== DEBUG: Profile Data Mapping ===');
      print('Basic Info:');
      print('- Name: ${userProfileData.firstName} ${userProfileData.lastName}');
      print('- Email: ${userProfileData.email}');
      print('- Age: ${userProfileData.age}');
      print('- Gender: ${userProfileData.gender}');
      print('- About Me: ${userProfileData.aboutMe}');
      print('- Religion: ${userProfileData.religion}');
      print('- Zodiac: ${userProfileData.zodiacSign}');
      
      print('\nLifestyle:');
      print('- Sleeping Style: ${userProfileData.lifestyle?.sleepingStyle}');
      print('- Love Style: ${userProfileData.lifestyle?.loveStyle}');
      print('- Weekends: ${userProfileData.lifestyle?.weekends}');
      print('- Traveling: ${userProfileData.lifestyle?.traveling}');
      print('- Home Environment: ${userProfileData.lifestyle?.homeEnvironment}');
      print('- Living Space: ${userProfileData.lifestyle?.livingSpace}');
      
      print('\nHabits:');
      print('- Communication Style: ${userProfileData.habits?.communicationStyle}');
      print('- Workout: ${userProfileData.habits?.workout}');
      print('- Eating Style: ${userProfileData.habits?.eatingStyle}');
      print('- Social Media: ${userProfileData.habits?.socialMedia}');
      print('- Smoke/Drink: ${userProfileData.habits?.smokeOrDrink}');
      print('- New Experiences: ${userProfileData.habits?.newExercise}');
      
      print('\nInterests:');
      print('- Hobbies: ${userProfileData.interests?.hobbies}');
      print('- Creative Outlets: ${userProfileData.interests?.creativeOutlets}');
      print('- Fitness/Sports: ${userProfileData.interests?.fitnessAndSports}');
      print('- Entertainment: ${userProfileData.interests?.entertainment}');
      print('- Leisure Activities: ${userProfileData.interests?.leisureActivities}');
      print('- Music Genres: ${userProfileData.interests?.musicGenres}');
      print('- Health/Wellness: ${userProfileData.interests?.healthAndWellness}');
      print('- Reading/Content: ${userProfileData.interests?.readingAndContent}');
      
      print('\nPreferences:');
      print('- Like to Meet: ${userProfileData.likeToMeet}');
      print('- Personal Traits: ${userProfileData.personalTraitsInspire}');
      print('- Relation Type: ${userProfileData.relationType}');
      
      print('\nProfile Status:');
      print('- Completion: ${userProfileData.profileCompletionPercentage}%');
      print('- Verified: ${userProfileData.isVerified}');
      print('- Status: ${userProfileData.status}');
      
      print('\nPhotos and Location:');
      print('- Images: ${userProfileData.image}');
      print('- Location: ${userProfileData.location != null ? 'Available' : 'Not set'}');
      print('==============================\n');
      
      // Set the profile data
      _userProfile.value = userProfileData;
      
      // Update profile completion
      _profileCompletion.value = userProfileData.profileCompletionPercentage;
      
      AppLogger.success('✅ [PROFILE MAPPING] API data mapped to UserProfile model successfully');
      AppLogger.info('📊 [PROFILE MAPPING] Profile completion: ${_profileCompletion.value}%');
      
      // Verify all required fields are present
      _verifyProfileData(userProfileData);
      
    } catch (e) {
      print('DEBUG: Error in _mapApiDataToController: $e');
      AppLogger.error('❌ [PROFILE MAPPING] Error mapping API data to UserProfile model: $e');
    }
  }
  
  /// Verify all required profile fields are present and log missing optional fields
  void _verifyProfileData(UserProfile profile) {
    List<String> missingRequiredFields = [];
    List<String> missingOptionalFields = [];
    
    // Check basic info (required)
    if (profile.firstName.isEmpty) missingRequiredFields.add('First Name');
    if (profile.age == null) missingRequiredFields.add('Age');
    if (profile.gender.isEmpty) missingRequiredFields.add('Gender');
    
    // Check lifestyle (optional)
    if (profile.lifestyle != null) {
      final lifestyle = profile.lifestyle!;
      if (lifestyle.sleepingStyle?.isEmpty ?? true) missingOptionalFields.add('Sleeping Style');
      if (lifestyle.loveStyle?.isEmpty ?? true) missingOptionalFields.add('Love Style');
      if (lifestyle.weekends?.isEmpty ?? true) missingOptionalFields.add('Weekend Preference');
      if (lifestyle.traveling?.isEmpty ?? true) missingOptionalFields.add('Travel Preference');
      if (lifestyle.homeEnvironment?.isEmpty ?? true) missingOptionalFields.add('Home Environment');
      if (lifestyle.livingSpace?.isEmpty ?? true) missingOptionalFields.add('Living Space');
    }
    
    // Check habits (partially required)
    if (profile.habits == null) {
      missingRequiredFields.add('Habits Information');
    } else {
      final habits = profile.habits!;
      // Required habit fields
      if (habits.communicationStyle.isEmpty) missingRequiredFields.add('Communication Style');
      if (habits.eatingStyle.isEmpty) missingRequiredFields.add('Eating Style');
      
      // Optional habit fields
      if (habits.workout?.isEmpty ?? true) missingOptionalFields.add('Workout Preference');
      if (habits.socialMedia?.isEmpty ?? true) missingOptionalFields.add('Social Media Usage');
      if (habits.smokeOrDrink?.isEmpty ?? true) missingOptionalFields.add('Smoking/Drinking Preference');
      if (habits.newExercise?.isEmpty ?? true) missingOptionalFields.add('New Experiences');
    }
    
    // Check interests (partially required)
    if (profile.interests == null) {
      missingRequiredFields.add('Interests Information');
    } else {
      final interests = profile.interests!;
      // Only check if ALL interest categories are empty
      bool hasAnyInterest = !(
        interests.hobbies.isEmpty &&
        interests.creativeOutlets.isEmpty &&
        interests.fitnessAndSports.isEmpty &&
        interests.entertainment.isEmpty &&
        interests.leisureActivities.isEmpty &&
        interests.musicGenres.isEmpty &&
        interests.healthAndWellness.isEmpty &&
        interests.readingAndContent.isEmpty
      );
      
      if (!hasAnyInterest) {
        missingRequiredFields.add('At least one interest category');
      }
    }
    
    // Check required preferences
    if (profile.likeToMeet.isEmpty) missingRequiredFields.add('Like to Meet Preferences');
    if (profile.personalTraitsInspire.isEmpty) missingRequiredFields.add('Personal Traits');
    if (profile.relationType?.isEmpty ?? true) missingRequiredFields.add('Relation Type');
    
    // Profile photo is optional during initial setup
    if (profile.image.isEmpty) missingOptionalFields.add('Profile Photos');
    
    // Log required missing fields with high priority
    if (missingRequiredFields.isNotEmpty) {
      AppLogger.warning('⚠️ [PROFILE MAPPING] Missing required fields:');
      for (var field in missingRequiredFields) {
        AppLogger.warning('  - $field');
      }
      
      // Show warning for missing required fields
      Get.snackbar(
        'Required Information Missing',
        'Please complete the required profile information to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
    }
    
    // Log optional missing fields with lower priority
    if (missingOptionalFields.isNotEmpty) {
      AppLogger.info('ℹ️ [PROFILE MAPPING] Optional fields that can be completed:');
      for (var field in missingOptionalFields) {
        AppLogger.info('  - $field');
      }
      
      // Show info for missing optional fields only if required fields are complete
      if (missingRequiredFields.isEmpty) {
        Get.snackbar(
          'Profile Enhancement',
          'Consider adding more details to enhance your profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: Duration(seconds: 4),
        );
      }
    }
    
    // Log success if all required fields are present
    if (missingRequiredFields.isEmpty) {
      AppLogger.success(' [PROFILE MAPPING] All required fields are present');
    }
  }
  
  /// Handle authentication errors (401)
  void _handleAuthError() {
    try {
      AppLogger.warning(' [PROFILE AUTH] Handling authentication error...');
      
      // Show user-friendly message instead of redirecting
      Get.snackbar(
        'Session Expired',
        'Please refresh the app or login again to continue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      AppLogger.info(' [PROFILE AUTH] User notified about session expiration');
    } catch (e) {
      AppLogger.error(' [PROFILE AUTH] Error handling auth error: $e');
    }
  }
  
  // Methods
  void updateProfileCompletion() {
    print('DEBUG: updateProfileCompletion() called');
    print('DEBUG: _userProfile.value: ${_userProfile.value}');
    print('DEBUG: profileCompletionPercentage getter: $profileCompletionPercentage');
    
    // Use the profile completion percentage from the model
    _profileCompletion.value = profileCompletionPercentage;
    print('DEBUG: _profileCompletion.value set to: ${_profileCompletion.value}');
  }
  
  void addPhoto(String photoUrl) {
    if (_userProfile.value != null) {
      final currentPhotos = List<String>.from(_userProfile.value!.image);
      if (currentPhotos.length < 6) {
        currentPhotos.add(photoUrl);
        _updateUserProfilePhotos(currentPhotos);
      }
    }
  }
  
  void removePhoto(int index) {
    if (_userProfile.value != null) {
      final currentPhotos = List<String>.from(_userProfile.value!.image);
      if (index >= 0 && index < currentPhotos.length) {
        currentPhotos.removeAt(index);
        _updateUserProfilePhotos(currentPhotos);
      }
    }
  }
  
  void _updateUserProfilePhotos(List<String> newPhotos) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: newPhotos,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit the update to the server
      _submitUpdate({'photos': newPhotos});
    }
  }
  
  void toggleTrait(String trait) {
    if (_userProfile.value != null) {
      final currentTraits = List<String>.from(_userProfile.value!.personalTraitsInspire);
      if (currentTraits.contains(trait)) {
        currentTraits.remove(trait);
      } else {
        currentTraits.add(trait);
      }
      _updateUserProfileTraits(currentTraits);
    }
  }
  
  void _updateUserProfileTraits(List<String> newTraits) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: newTraits,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit the update to the server
      _submitUpdate({'personalTraitsInspire': newTraits});
    }
  }
  
  void toggleInterest(String interest) {
    // Note: Interests are complex and nested, this would need more sophisticated handling
    // For now, this is a placeholder for interest toggling logic
    AppLogger.info('🔄 [PROFILE] Toggle interest: $interest (needs complex implementation)');
  }
  
  void updateAboutMe(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: value,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit update to server
      _submitUpdate({'aboutMe': value});
    }
  }
  
  /// Refresh profile data
  Future<void> refreshProfileData() async {
    await _loadProfileData();
  }

  // Update methods for profile fields
  void updateName(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: value,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit the update to the server  
      _submitUpdate({'firstName': value});
    }
  }

  void updateAge(String value) {
    if (_userProfile.value != null) {
      final age = int.tryParse(value);
      if (age != null) {
        final currProfile = _userProfile.value!;
        final updatedProfile = UserProfile(
          id: currProfile.id,
          role: currProfile.role,
          email: currProfile.email,
          age: age,
          gender: currProfile.gender,
          firstName: currProfile.firstName,
          lastName: currProfile.lastName,
          aboutMe: currProfile.aboutMe,
          religion: currProfile.religion,
          zodiacSign: currProfile.zodiacSign,
          status: currProfile.status,
          isVerified: currProfile.isVerified,
          profileCompletionPercentage: currProfile.profileCompletionPercentage,
          isDeleted: currProfile.isDeleted,
          createdAt: currProfile.createdAt,
          updatedAt: currProfile.updatedAt,
          habits: currProfile.habits,
          interests: currProfile.interests,
          lifestyle: currProfile.lifestyle,
          likeToMeet: currProfile.likeToMeet,
          personalTraitsInspire: currProfile.personalTraitsInspire,
          image: currProfile.image,
          phone: currProfile.phone,
          relationType: currProfile.relationType,
          location: currProfile.location,
        );
        _userProfile.value = updatedProfile;
        
        // Submit update to server
        _submitUpdate({'age': age});
      }
    }
  }

  void updateGender(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: value,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit update to server
      _submitUpdate({'gender': value});
    }
  }

  void updateReligion(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: value,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit update to server
      _submitUpdate({'religion': value});
    }
  }

  void updateZodiac(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: value,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit update to server
      _submitUpdate({'zodiacSign': value});
      _submitUpdate({'zodiacSign': value});
    }
  }

  // Lifestyle update methods
  void updateHeight(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: value,  // Using sleepingStyle as placeholder for height
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: updatedLifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
      
      // Submit update to server
      _submitUpdate({'lifestyle': {'sleepingStyle': value}});
    }
  }

  void updateWeight(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: value,  // Using loveStyle as placeholder for weight
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );

      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'loveStyle': value}});
    }
  }

  void updateEducation(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: value,  // Using weekends as placeholder for education
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );

      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'weekends': value}});
    }
  }

  void updateJobStatus(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: value,  // Using traveling as placeholder for job status
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );

      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'traveling': value}});
    }
  }

  void _updateUserProfileWithLifestyle(Lifestyle lifestyle) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
    }
  }

  // Habits update methods
  void updateCommunicationStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: [value],
        workout: oldHabits.workout,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'communicationStyle': [value]}});
    }
  }

  void updateWorkout(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: value,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'workout': value}});
    }
  }

  void updateEatingStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: oldHabits.workout,
        eatingStyle: [value],
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'eatingStyle': [value]}});
    }
  }

  void updateSocialMedia(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: oldHabits.workout,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: value,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'socialMedia': value}});
    }
  }

  void updateSmokeOrDrink(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: oldHabits.workout,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: value,
        newExercise: oldHabits.newExercise,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'smokeOrDrink': value}});
    }
  }

  void updateNewExperiences(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: oldHabits.workout,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: value,
      );

      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'newExercise': value}});
    }
  }

  void _updateUserProfileWithHabits(Habits habits) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final updatedProfile = UserProfile(
        id: currProfile.id,
        role: currProfile.role,
        email: currProfile.email,
        age: currProfile.age,
        gender: currProfile.gender,
        firstName: currProfile.firstName,
        lastName: currProfile.lastName,
        aboutMe: currProfile.aboutMe,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,
        isVerified: currProfile.isVerified,
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
      );
      _userProfile.value = updatedProfile;
    }
  }

  // Common lists for dropdowns from AccountsController
  // Religious preferences
  final religions = [
    'Agnostic', 'Atheist', 'Buddhist', 'Christian', 'Hindu',
    'Jewish', 'Muslim', 'Sikh', 'Spiritual', 'Prefer not to say',
  ];

  // Zodiac signs
  final zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius',
    'Pisces', 'Not sure', 'Prefer not to say',
  ];

  // Communication preferences
  final communicationStyles = [
    'Good texter', 'Bad texter', 'Video Chatter', 'Phone caller'
  ];

  // Exercise habits
  final exerciseFrequencies = [
    'Yes', 'Several times a week', 'Rarely', 'Never'
  ];

  // Food preferences
  final foodPreferences = [
    'Healthy and balanced', 'Whatever I feel like', 'Specific diet', "I don't eat"
  ];

  // Social media usage
  final socialMediaUsage = [
    'Yes', 'Occasionally', 'Frequently', 'Rarely', 'Never'
  ];

  // Smoking and drinking habits
  final smokingDrinking = [
    'Yes', 'Occasionally', 'No'
  ];

  // Experience preferences
  final newExperienceOptions = [
    'Absolutely', 'Sometimes', 'Rarely', 'Never'
  ];

  // Gender options
  final genders = [
    'Woman', 'Trans woman', 'Men', 'Trans men', 'Nonbinary'
  ];

  // Education levels
  final educationLevels = [
    'High School',
    'Some College',
    'Associates Degree',
    "Bachelor's Degree",
    "Master's Degree",
    'Doctorate',
    'Trade School',
    'Other',
    'Prefer not to say'
  ];

  // Job status options
  final jobStatuses = [
    'Student',
    'Employed Full-time',
    'Employed Part-time',
    'Self-employed',
    'Freelancer',
    'Looking for work',
    'Not working',
    'Retired',
    'Prefer not to say'
  ];

  // Income range options
  final incomeRanges = [
    'Under \$5,000',
    '\$25,000 - \$50,000',
    '\$50,000 - \$75,000',
    '\$75,000 - \$100,000',
    '\$100,000 - \$150,000',
    'Over \$150,000',
    'Prefer not to say'
  ];

  // Day preferences
  final dayPreferences = [
    'Morning Person',
    'Night Owl',
    'In Between',
    'Depends on the day'
  ];

  // Love languages
  final loveLanguages = [
    'Words of Affirmation',
    'Quality Time',
    'Receiving Gifts',
    'Acts of Service',
    'Physical Touch'
  ];

  // Weekend activities
  final weekendActivities = [
    'Relaxing at home',
    'Going out with friends',
    'Exploring new places',
    'Pursuing hobbies',
    'Catching up on work/errands'
  ];

  // Travel preferences
  final travelPreferences = [
    'Love traveling',
    'Like it occasionally',
    'Prefer staying local',
    'Depends on the destination'
  ];

  // Home environment preferences
  final homeEnvironments = [
    'Neat and organized',
    'Comfortably messy',
    'Minimalist',
    'Cozy and decorated',
    'Practical',
    'Always changing'
  ];

  // Living situation
  final livingSpaces = [
    'Live alone',
    'With roommates',
    'With family',
    'With partner',
    'Frequently moving',
    'Other'
  ];

  // Submit updates to the server
  Future<void> _submitUpdate(Map<String, dynamic> data) async {
    try {
      AppLogger.info('🔄 [PROFILE CONTROLLER] Submitting profile update...');
      AppLogger.info('📋 [PROFILE CONTROLLER] Update data: $data');
      
      if (LocalStorage.token.isEmpty) {
        AppLogger.warning('❌ [PROFILE CONTROLLER] No access token found');
        Get.snackbar(
          'Error',
          'Please login again to update your profile',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;
      final response = await _profileService.updateProfile(data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ [PROFILE CONTROLLER] Profile updated successfully');
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Refresh profile data to get the latest changes
        await refreshProfileData();
      } else {
        AppLogger.warning('⚠️ [PROFILE CONTROLLER] Unexpected response: ${response.statusCode}');
        Get.snackbar(
          'Warning',
          'Profile may not be fully updated',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [PROFILE CONTROLLER] DioException: ${e.message}', e, e.stackTrace);
      String errorMessage = 'Failed to update profile';
      
      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please login again.';
        _handleAuthError();
      } else if (e.response?.data != null) {
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
        } else {
          errorMessage = e.response?.data.toString() ?? errorMessage;
        }
      }
      
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Error updating profile: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while updating profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}