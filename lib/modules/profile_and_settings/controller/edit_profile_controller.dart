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
  
  // Temporary about me text controller for unsaved changes
  late TextEditingController aboutMeController;
  final isAboutMeDirty = RxBool(false);
  
  // Text editing controllers for editable fields
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController educationController;
  late TextEditingController jobStatusController;
  late TextEditingController locationController;
  
  // Edit mode state
  final isEditMode = RxBool(false);
  
  // Dropdown options
  final List<String> genders = ['Male', 'Female', 'Non-binary', 'Trans man', 'Trans woman', 'Prefer not to say'];
  final List<String> zodiacSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  final List<String> religions = ['Christianity', 'Islam', 'Hinduism', 'Buddhism', 'Judaism', 'Sikhism', 'Spiritual', 'Agnostic', 'Atheist', 'Other'];
  
  // Lifestyle preferences
  final List<String> sleepingStyles = ['Early bird', 'Night owl', 'Flexible'];
  final List<String> loveStyles = ['Romantic', 'Practical', 'Adventurous', 'Traditional', 'Modern'];
  final List<String> weekendPreferences = ['Homebody', 'Social butterfly', 'Adventure seeker', 'Relaxation focused'];
  final List<String> travelingPreferences = ['Love traveling', 'Prefer staying local', 'Occasional traveler'];
  final List<String> homeEnvironments = ['Cozy', 'Modern', 'Minimalist', 'Traditional', 'Eclectic'];
  final List<String> livingSpaces = ['House', 'Apartment', 'Condo', 'Shared housing'];
  
  // Habits
  final List<String> communicationStyles = ['Direct', 'Diplomatic', 'Reserved', 'Expressive'];
  final List<String> exerciseFrequencies = ['Daily', '3-4 times/week', '1-2 times/week', 'Occasionally', 'Never'];
  final List<String> foodPreferences = ['Omnivore', 'Vegetarian', 'Vegan', 'Pescatarian', 'Keto', 'Gluten-free'];
  final List<String> socialMediaUsage = ['Very active', 'Moderately active', 'Occasionally', 'Rarely', 'Never'];
  final List<String> smokingDrinking = ['Non-smoker, Non-drinker', 'Social drinker', 'Smoker', 'Both smoker and drinker'];
  final List<String> newExperienceOptions = ['Love trying new things', 'Open to new experiences', 'Prefer familiar things', 'Selective about new experiences'];
  
  // Selected dropdown values
  final RxString selectedGender = ''.obs;
  final RxString selectedZodiac = ''.obs;
  final RxString selectedReligion = ''.obs;
  final RxString selectedSleepingStyle = ''.obs;
  final RxString selectedLoveStyle = ''.obs;
  final RxString selectedWeekends = ''.obs;
  final RxString selectedTraveling = ''.obs;
  final RxString selectedHomeEnvironment = ''.obs;
  final RxString selectedLivingSpace = ''.obs;
  final RxString selectedCommunicationStyle = ''.obs;
  final RxString selectedExerciseFrequency = ''.obs;
  final RxString selectedFoodPreference = ''.obs;
  final RxString selectedSocialMediaUsage = ''.obs;
  final RxString selectedSmokingDrinking = ''.obs;
  final RxString selectedNewExperiences = ''.obs;
  
  // Education levels
  final List<String> educationLevels = [
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
  final List<String> jobStatuses = [
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

  // Weekend styles (alias for weekendPreferences)
  List<String> get weekendStyles => weekendPreferences;

  // Traveling styles (alias for travelingPreferences)
  List<String> get travelingStyles => travelingPreferences;

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

  String get userHeight => _userProfile.value?.body?.heightCm?.toString() ?? '';
  String get userWeight => _userProfile.value?.body?.weightKg?.toString() ?? '';
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
  
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) {
      _initializeControllersForEdit();
    }
  }
  
  void cancelEditMode() {
    isEditMode.value = false;
    _resetControllersToProfileData();
  }
  
  void _initializeControllersForEdit() {
    if (_userProfile.value != null) {
      nameController.text = _userProfile.value!.firstName ?? '';
      ageController.text = _userProfile.value!.age?.toString() ?? '';
      heightController.text = _userProfile.value!.body?.heightCm?.toString() ?? '';
      weightController.text = _userProfile.value!.body?.weightKg?.toString() ?? '';
      educationController.text = _userProfile.value!.eduJob?.educationLevel ?? '';
      jobStatusController.text = _userProfile.value!.eduJob?.jobTitle ?? '';
      locationController.text = _userProfile.value!.location?.toString() ?? '';
      
      // Initialize dropdown selections
      selectedGender.value = _userProfile.value!.gender ?? '';
      selectedZodiac.value = _userProfile.value!.zodiacSign ?? '';
      selectedReligion.value = _userProfile.value!.religion ?? '';
      selectedSleepingStyle.value = _userProfile.value!.lifestyle?.sleepingStyle ?? '';
      selectedLoveStyle.value = _userProfile.value!.lifestyle?.loveStyle ?? '';
      selectedWeekends.value = _userProfile.value!.lifestyle?.weekends ?? '';
      selectedTraveling.value = _userProfile.value!.lifestyle?.traveling ?? '';
      selectedCommunicationStyle.value = _userProfile.value!.habits!.communicationStyle.join(', ');
      selectedExerciseFrequency.value = _userProfile.value!.habits!.workout ?? '';
      selectedFoodPreference.value = _userProfile.value!.habits!.eatingStyle.join(', ');
      selectedSocialMediaUsage.value = _userProfile.value!.habits!.socialMedia ?? '';
      selectedSmokingDrinking.value = _userProfile.value!.habits!.smokeOrDrink ?? '';
      selectedNewExperiences.value = _userProfile.value!.habits!.newExercise ?? '';
    }
  }
  
  void _resetControllersToProfileData() {
    _initializeControllersForEdit(); // Reset to current profile data
  }
  
  void _updateProfileCompletionFromControllers() {
    // This method updates profile completion based on controller values
    // Implementation will sync controller values with profile data and update completion
    updateProfileCompletion();
  }
  
  // Location
  String get location => profile?.location != null ? 'Location available' : '';
  
  // Additional getters for compatibility with existing UI
  String get height => userHeight;
  String get weight => userWeight;
  String get education => userWeekend;
  String get jobStatus => userTravelling;
  String get lookingFor => userRelationType;
  
  @override
  void onInit() {
    super.onInit();
    // Initialize all text controllers
    aboutMeController = TextEditingController();
    nameController = TextEditingController();
    ageController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    educationController = TextEditingController();
    jobStatusController = TextEditingController();
    locationController = TextEditingController();
    
    // Add listeners for text changes to update profile completion
    nameController.addListener(_updateProfileCompletionFromControllers);
    ageController.addListener(_updateProfileCompletionFromControllers);
    heightController.addListener(_updateProfileCompletionFromControllers);
    weightController.addListener(_updateProfileCompletionFromControllers);
    educationController.addListener(_updateProfileCompletionFromControllers);
    jobStatusController.addListener(_updateProfileCompletionFromControllers);
    locationController.addListener(_updateProfileCompletionFromControllers);
    
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
      
      print('- Status: ${userProfileData.status}');
      
      print('\nPhotos and Location:');
      print('- Images: ${userProfileData.image}');
      print('- Location: ${userProfileData.location != null ? 'Available' : 'Not set'}');
      print('==============================\n');
      
      // Set the profile data
      _userProfile.value = userProfileData;
      
      // Initialize about me controller with current data
      _initializeAboutMeController();
      
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

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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
  
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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
    // Update the temporary controller text
    aboutMeController.text = value;
    // Mark as dirty (has unsaved changes)
    isAboutMeDirty.value = true;

    AppLogger.info('✏️ [ABOUT ME] About me text updated locally: ${value.length} characters');
  }
  
  /// Submit about me text to backend only when button is pressed
  Future<void> submitAboutMe() async {
    if (!isAboutMeDirty.value) {
      AppLogger.info('ℹ️ [ABOUT ME] No changes to submit');
      return;
    }
    
    final aboutMeText = aboutMeController.text;
    AppLogger.info('📤 [ABOUT ME] Submitting about me to backend: ${aboutMeText.length} characters');
    
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
        aboutMe: aboutMeText,
        religion: currProfile.religion,
        zodiacSign: currProfile.zodiacSign,
        status: currProfile.status,

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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
      await _submitUpdate({'aboutMe': aboutMeText});
      
      // Mark as clean (no unsaved changes)
      isAboutMeDirty.value = false;
      
      AppLogger.success('✅ [ABOUT ME] About me submitted successfully');
    }
  }
  
  /// Initialize about me controller with current profile data
  void _initializeAboutMeController() {
    if (_userProfile.value != null) {
      aboutMeController.text = _userProfile.value!.aboutMe ?? '';
      isAboutMeDirty.value = false;
      AppLogger.info('🔄 [ABOUT ME] About me controller initialized with ${aboutMeController.text.length} characters');
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

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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

          profileCompletionPercentage: currProfile.profileCompletionPercentage,
          isDeleted: currProfile.isDeleted,
          isVerified: currProfile.isVerified,
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

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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

        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
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
    }
  }

  // Body update methods
  void updateHeight(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final oldBody = currProfile.body;
      final heightValue = double.tryParse(value);

      final updatedBody = Body(
        heightCm: heightValue,
        weightKg: oldBody?.weightKg,
      );

      _updateUserProfileWithBody(updatedBody);
      _submitUpdate({'body': {'heightCm': heightValue}});
    }
  }

  void updateWeight(String value) {
    if (_userProfile.value != null) {
      final currProfile = _userProfile.value!;
      final oldBody = currProfile.body;
      final weightValue = double.tryParse(value);

      final updatedBody = Body(
        heightCm: oldBody?.heightCm,
        weightKg: weightValue,
      );

      _updateUserProfileWithBody(updatedBody);
      _submitUpdate({'body': {'weightKg': weightValue}});
    }
  }

  /// Update basic profile information (name, age, gender, height, weight) together
  Future<void> updateBasicProfileInfo() async {
    try {
      AppLogger.info('🔄 [PROFILE CONTROLLER] Updating basic profile information...');

      if (_userProfile.value == null) {
        AppLogger.warning('❌ [PROFILE CONTROLLER] No profile data available');
        Get.snackbar(
          'Error',
          'No profile data available',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Validate required fields
      if (nameController.text.isEmpty) {
        Get.snackbar(
          'Required Field',
          'Name is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (ageController.text.isEmpty) {
        Get.snackbar(
          'Required Field',
          'Age is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      if (selectedGender.value.isEmpty) {
        Get.snackbar(
          'Required Field',
          'Gender is required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      isLoading.value = true;

      // Update each field individually using existing methods
      if (nameController.text != _userProfile.value!.firstName) {
        updateName(nameController.text);
      }

      final newAge = int.tryParse(ageController.text);
      if (newAge != null && newAge != _userProfile.value!.age) {
        updateAge(ageController.text);
      }

      if (selectedGender.value != _userProfile.value!.gender) {
        updateGender(selectedGender.value);
      }

      if (heightController.text != userHeight && heightController.text.isNotEmpty) {
        updateHeight(heightController.text);
      }

      if (weightController.text != userWeight && weightController.text.isNotEmpty) {
        updateWeight(weightController.text);
      }

      AppLogger.success('✅ [PROFILE CONTROLLER] Basic profile information update initiated');
      Get.snackbar(
        'Success',
        'Profile information updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

    } catch (e) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Error updating basic profile info: $e');
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

  /// Update user profile with new lifestyle data
  void _updateUserProfileWithLifestyle(Lifestyle updatedLifestyle) {
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
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: updatedLifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        bodyImage: currProfile.bodyImage,
        headShotImage: currProfile.headShotImage,
        personalityImage: currProfile.personalityImage,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
        body: currProfile.body,
        eduJob: currProfile.eduJob,
        beliefsOtherText: currProfile.beliefsOtherText,
        address: currProfile.address,
        traitsOtherText: currProfile.traitsOtherText,
      );
      _userProfile.value = updatedProfile;
    }
  }

  /// Update user profile with new body data
  void _updateUserProfileWithBody(Body updatedBody) {
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
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: currProfile.habits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        bodyImage: currProfile.bodyImage,
        headShotImage: currProfile.headShotImage,
        personalityImage: currProfile.personalityImage,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
        body: updatedBody,
        eduJob: currProfile.eduJob,
        beliefsOtherText: currProfile.beliefsOtherText,
        address: currProfile.address,
        traitsOtherText: currProfile.traitsOtherText,
      );
      _userProfile.value = updatedProfile;
    }
  }

  /// Submit profile updates to the server
  Future<void> _submitUpdate(Map<String, dynamic> data) async {
    if (!isProfileServiceInitialized) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Profile service not initialized');
      return;
    }

    try {
      AppLogger.info('📤 [PROFILE CONTROLLER] Submitting profile update: $data');
      
      final response = await _profileService.updateProfile(data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ [PROFILE CONTROLLER] Profile update successful');
        
        // Refresh profile data to get latest updates
        await _loadProfileData();
        
        // Show success message
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      AppLogger.error('❌ [PROFILE CONTROLLER] Dio error updating profile: ${e.message}', e, e.stackTrace);
      
      String errorMessage = 'Failed to update profile';
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
      AppLogger.error('❌ [PROFILE CONTROLLER] Unexpected error updating profile: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred while updating profile.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Habits update methods
  void updateCommunicationStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      
      // Convert single selection to list format
      final List<String> communicationStyles = [value];
      
      final updatedHabits = Habits(
        communicationStyle: communicationStyles,
        workout: oldHabits.workout,
        eatingStyle: oldHabits.eatingStyle,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );
      
      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'communicationStyle': communicationStyles}});
      
      AppLogger.info('✏️ [HABITS] Communication style updated: $value');
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
      
      AppLogger.info('✏️ [HABITS] Workout frequency updated: $value');
    }
  }

  void updateEatingStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.habits != null) {
      final currProfile = _userProfile.value!;
      final oldHabits = currProfile.habits!;
      
      // Convert single selection to list format
      final List<String> eatingStyles = [value];
      
      final updatedHabits = Habits(
        communicationStyle: oldHabits.communicationStyle,
        workout: oldHabits.workout,
        eatingStyle: eatingStyles,
        socialMedia: oldHabits.socialMedia,
        smokeOrDrink: oldHabits.smokeOrDrink,
        newExercise: oldHabits.newExercise,
      );
      
      _updateUserProfileWithHabits(updatedHabits);
      _submitUpdate({'habits': {'eatingStyle': eatingStyles}});
      
      AppLogger.info('✏️ [HABITS] Eating style updated: $value');
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
      
      AppLogger.info('✏️ [HABITS] Social media usage updated: $value');
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
      _submitUpdate({'habits': {'smokingOrDrinking': value}});
      
      AppLogger.info('✏️ [HABITS] Smoke/drink habits updated: $value');
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
      
      AppLogger.info('✏️ [HABITS] New experiences preference updated: $value');
    }
  }

  /// Update user profile with new habits data
  void _updateUserProfileWithHabits(Habits updatedHabits) {
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
        profileCompletionPercentage: currProfile.profileCompletionPercentage,
        isDeleted: currProfile.isDeleted,
        isVerified: currProfile.isVerified,
        createdAt: currProfile.createdAt,
        updatedAt: currProfile.updatedAt,
        habits: updatedHabits,
        interests: currProfile.interests,
        lifestyle: currProfile.lifestyle,
        likeToMeet: currProfile.likeToMeet,
        personalTraitsInspire: currProfile.personalTraitsInspire,
        image: currProfile.image,
        bodyImage: currProfile.bodyImage,
        headShotImage: currProfile.headShotImage,
        personalityImage: currProfile.personalityImage,
        phone: currProfile.phone,
        relationType: currProfile.relationType,
        location: currProfile.location,
        body: currProfile.body,
        eduJob: currProfile.eduJob,
        beliefsOtherText: currProfile.beliefsOtherText,
        address: currProfile.address,
        traitsOtherText: currProfile.traitsOtherText,
      );
      _userProfile.value = updatedProfile;
    }
  }

  // Education and Career update methods
  void updateEducation(String value) {
    if (_userProfile.value != null) {
      // For education, we need to update the profile's education field
      // This might be part of a more complex education/career structure
      _submitUpdate({'education': value});
      
      AppLogger.info('✏️ [EDUCATION] Education level updated: $value');
    }
  }

  void updateJobStatus(String value) {
    if (_userProfile.value != null) {
      // For job status, we need to update the profile's job status field
      _submitUpdate({'jobStatus': value});
      
      AppLogger.info('✏️ [CAREER] Job status updated: $value');
    }
  }

  // Lifestyle update methods
  void updateSleepingStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: value,
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'sleepingStyle': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Sleeping style updated: $value');
    }
  }

  void updateLoveStyle(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: value,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'loveStyle': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Love style updated: $value');
    }
  }

  void updateWeekend(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: value,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'weekends': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Weekend preference updated: $value');
    }
  }

  void updateTravelling(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: value,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'traveling': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Traveling preference updated: $value');
    }
  }

  void updateHomeEnvironment(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: value,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'homeEnvironment': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Home environment updated: $value');
    }
  }

  void updateLivingSpace(String value) {
    if (_userProfile.value != null && _userProfile.value!.lifestyle != null) {
      final currProfile = _userProfile.value!;
      final oldLifestyle = currProfile.lifestyle!;
      
      final updatedLifestyle = Lifestyle(
        sleepingStyle: oldLifestyle.sleepingStyle,
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: value,
      );
      
      _updateUserProfileWithLifestyle(updatedLifestyle);
      _submitUpdate({'lifestyle': {'livingSpace': value}});
      
      AppLogger.info('✏️ [LIFESTYLE] Living space updated: $value');
    }
  }
}