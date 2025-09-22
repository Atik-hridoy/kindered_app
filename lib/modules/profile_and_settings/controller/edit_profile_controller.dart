import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/services/profile_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileEditController extends GetxController {
  // Profile service for API calls
  late ProfileService _profileService;
  
  // Loading state
  var isLoading = false.obs;
  
  // Profile model
  var userProfile = Rx<UserProfile?>(null);
  
  // Profile completion percentage
  var profileCompletion = 0.obs;
  
  // Personal Information (computed from model)
  String get name => userProfile.value?.firstName ?? '';
  String get email => userProfile.value?.email ?? '';
  String get age => userProfile.value?.age?.toString() ?? '';
  String get gender => userProfile.value?.gender ?? '';
  String get aboutMe => userProfile.value?.aboutMe ?? '';
  String get religion => userProfile.value?.religion ?? '';
  String get zodiac => userProfile.value?.zodiacSign ?? '';
  int get profileCompletionPercentage => userProfile.value?.profileCompletionPercentage ?? 0;
  
  // Photos
  List<String> get photos => userProfile.value?.image ?? [];
  
  // Personal Traits
  List<String> get selectedTraits => userProfile.value?.personalTraitsInspire ?? [];
  
  // Interests
  List<String> get selectedInterests {
    final interests = userProfile.value?.interests;
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
  
  // Gender preferences
  List<String> get interestedIn => userProfile.value?.likeToMeet ?? [];
  
  // Habits (computed from model)
  List<String> get communicationStyle => userProfile.value?.habits?.communicationStyle ?? [];
  String get workout => userProfile.value?.habits?.workout ?? '';
  List<String> get eatingStyle => userProfile.value?.habits?.eatingStyle ?? [];
  String get socialMedia => userProfile.value?.habits?.socialMedia ?? '';
  String get smokeOrDrink => userProfile.value?.habits?.smokeOrDrink ?? '';
  String get newExperiences => userProfile.value?.habits?.newExercise ?? '';
  
  // Lifestyle preferences (computed from model)
  String get sleepingStyle => userProfile.value?.lifestyle?.sleepingStyle ?? '';
  String get loveStyle => userProfile.value?.lifestyle?.loveStyle ?? '';
  String get weekend => userProfile.value?.lifestyle?.weekends ?? '';
  String get travelling => userProfile.value?.lifestyle?.traveling ?? '';
  String get homeEnvironment => userProfile.value?.lifestyle?.homeEnvironment ?? '';
  String get livingSpace => userProfile.value?.lifestyle?.livingSpace ?? '';
  
  // Location
  String get location => userProfile.value?.location != null ? 'Location available' : '';
  
  // Additional getters for compatibility with existing UI
  String get height => userProfile.value?.lifestyle?.sleepingStyle ?? '';
  String get weight => userProfile.value?.lifestyle?.loveStyle ?? '';
  String get education => userProfile.value?.lifestyle?.weekends ?? '';
  String get jobStatus => userProfile.value?.lifestyle?.traveling ?? '';
  String get lookingFor => userProfile.value?.relationType ?? '';
  
  @override
  void onInit() {
    super.onInit();
    print('DEBUG: ProfileEditController.onInit() called');
    _initializeProfileService();
    _loadProfileData();
    print('DEBUG: ProfileEditController.onInit() completed');
  }
  
  void _initializeProfileService() {
    print('DEBUG: _initializeProfileService() called');
    print('DEBUG: LocalStorage.token: ${LocalStorage.token}');
    print('DEBUG: LocalStorage.token.isEmpty: ${LocalStorage.token.isEmpty}');
    
    try {
      if (LocalStorage.token.isNotEmpty) {
        AppLogger.info('🔐 Initializing ProfileService with token (len=${LocalStorage.token.length})');
        _profileService = ProfileService(LocalStorage.token);
        print('DEBUG: ProfileService initialized successfully');
      } else {
        print('DEBUG: No token found - showing error snackbar');
        AppLogger.warning('❌ Missing bearer token. Cannot initialize ProfileService');
        Get.snackbar(
          'Authentication Required',
          'Please sign in to view your profile.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('DEBUG: Error in _initializeProfileService: $e');
      AppLogger.error('❌ Error initializing ProfileService: $e');
    }
  }
  
  /// Load profile data from API
  Future<void> _loadProfileData() async {
    print('DEBUG: _loadProfileData() called');
    print('DEBUG: LocalStorage.token: ${LocalStorage.token}');
    print('DEBUG: LocalStorage.token.isEmpty: ${LocalStorage.token.isEmpty}');
    
    if (LocalStorage.token.isEmpty) {
      AppLogger.warning('❌ No access token found');
      return;
    }
    
    isLoading.value = true;
    print('DEBUG: isLoading set to true');
    try {
      AppLogger.info('🔄 [PROFILE LOAD] Loading profile data from API...');
      
      // Fetch profile data from API
      print('DEBUG: Calling _profileService.getProfile()...');
      final response = await _profileService.getProfile();
      print('DEBUG: API response received');
      print('DEBUG: Response status code: ${response.statusCode}');
      print('DEBUG: Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final profileData = response.data;
        AppLogger.info('📋 [PROFILE LOAD] Profile data received: $profileData');
        
        // Map API response to controller variables
        print('DEBUG: Calling _mapApiDataToController...');
        _mapApiDataToController(profileData);
        
        // Update profile completion
        print('DEBUG: Calling updateProfileCompletion...');
        updateProfileCompletion();
        
        AppLogger.success('✅ [PROFILE LOAD] Profile data loaded successfully');
      } else {
        print('DEBUG: API response not successful or data is null');
        AppLogger.warning('⚠️ [PROFILE LOAD] Unexpected response: ${response.statusCode}');
        Get.snackbar(
          'Error',
          'Failed to fetch profile data. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } on DioException catch (e) {
      print('DEBUG: DioException caught: ${e.message}');
      print('DEBUG: DioException response: ${e.response}');
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
  
  /// Map API response data to UserProfile model
  void _mapApiDataToController(Map<String, dynamic> data) {
    try {
      AppLogger.info('🔄 [PROFILE MAPPING] Mapping API data to UserProfile model...');
      print('DEBUG: Raw API data: $data');
      
      // Extract the actual profile data from the response wrapper
      final profileData = data['data'] as Map<String, dynamic>;
      print('DEBUG: Extracted profile data: $profileData');
      
      // Create UserProfile from API data
      final userProfileData = UserProfile.fromJson(profileData);
      print('DEBUG: Created UserProfile: $userProfileData');
      print('DEBUG: Profile completion from model: ${userProfileData.profileCompletionPercentage}');
      print('DEBUG: First name from model: ${userProfileData.firstName}');
      
      userProfile.value = userProfileData;
      print('DEBUG: userProfile.value set to: ${userProfile.value}');
      
      // Update profile completion
      profileCompletion.value = userProfileData.profileCompletionPercentage;
      print('DEBUG: profileCompletion.value set to: ${profileCompletion.value}');
      
      AppLogger.success('✅ [PROFILE MAPPING] API data mapped to UserProfile model successfully');
    } catch (e) {
      print('DEBUG: Error in _mapApiDataToController: $e');
      AppLogger.error('❌ [PROFILE MAPPING] Error mapping API data to UserProfile model: $e');
    }
  }
  
  /// Handle authentication errors (401)
  void _handleAuthError() {
    try {
      AppLogger.warning('🔐 [PROFILE AUTH] Handling authentication error...');
      
      // Clear local storage
      LocalStorage.token = '';
      LocalStorage.isLogIn = false;
      LocalStorage.userId = '';
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      
      AppLogger.info('✅ [PROFILE AUTH] User redirected to login screen');
    } catch (e) {
      AppLogger.error('❌ [PROFILE AUTH] Error handling auth error: $e');
    }
  }
  
  // Methods
  void updateProfileCompletion() {
    print('DEBUG: updateProfileCompletion() called');
    print('DEBUG: userProfile.value: ${userProfile.value}');
    print('DEBUG: profileCompletionPercentage getter: $profileCompletionPercentage');
    
    // Use the profile completion percentage from the model
    profileCompletion.value = profileCompletionPercentage;
    print('DEBUG: profileCompletion.value set to: ${profileCompletion.value}');
  }
  
  void addPhoto(String photoUrl) {
    if (userProfile.value != null) {
      final currentPhotos = List<String>.from(userProfile.value!.image);
      if (currentPhotos.length < 6) {
        currentPhotos.add(photoUrl);
        _updateUserProfilePhotos(currentPhotos);
      }
    }
  }
  
  void removePhoto(int index) {
    if (userProfile.value != null) {
      final currentPhotos = List<String>.from(userProfile.value!.image);
      if (index >= 0 && index < currentPhotos.length) {
        currentPhotos.removeAt(index);
        _updateUserProfilePhotos(currentPhotos);
      }
    }
  }
  
  void _updateUserProfilePhotos(List<String> newPhotos) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: newPhotos,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
    }
  }
  
  void toggleTrait(String trait) {
    if (userProfile.value != null) {
      final currentTraits = List<String>.from(userProfile.value!.personalTraitsInspire);
      if (currentTraits.contains(trait)) {
        currentTraits.remove(trait);
      } else {
        currentTraits.add(trait);
      }
      _updateUserProfileTraits(currentTraits);
    }
  }
  
  void _updateUserProfileTraits(List<String> newTraits) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: newTraits,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
    }
  }
  
  void toggleInterest(String interest) {
    // Note: Interests are complex and nested, this would need more sophisticated handling
    // For now, this is a placeholder for interest toggling logic
    AppLogger.info('🔄 [PROFILE] Toggle interest: $interest (needs complex implementation)');
  }
  
  void updateAboutMe(String value) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: value,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
    }
  }
  
  /// Refresh profile data
  Future<void> refreshProfileData() async {
    await _loadProfileData();
  }

  // Update methods for profile fields
  void updateName(String value) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: value, // Updated value
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
      _submitUpdate({'firstName': value});
    }
  }

  void updateAge(String value) {
    if (userProfile.value != null) {
      final age = int.tryParse(value);
      if (age != null) {
        final updatedProfile = UserProfile(
          id: userProfile.value!.id,
          role: userProfile.value!.role,
          email: userProfile.value!.email,
          age: age, // Updated value
          gender: userProfile.value!.gender,
          firstName: userProfile.value!.firstName,
          lastName: userProfile.value!.lastName,
          aboutMe: userProfile.value!.aboutMe,
          religion: userProfile.value!.religion,
          zodiacSign: userProfile.value!.zodiacSign,
          status: userProfile.value!.status,
          isVerified: userProfile.value!.isVerified,
          profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
          isDeleted: userProfile.value!.isDeleted,
          createdAt: userProfile.value!.createdAt,
          updatedAt: userProfile.value!.updatedAt,
          habits: userProfile.value!.habits,
          interests: userProfile.value!.interests,
          lifestyle: userProfile.value!.lifestyle,
          likeToMeet: userProfile.value!.likeToMeet,
          personalTraitsInspire: userProfile.value!.personalTraitsInspire,
          image: userProfile.value!.image,
          phone: userProfile.value!.phone,
          relationType: userProfile.value!.relationType,
          location: userProfile.value!.location,
        );
        userProfile.value = updatedProfile;
        _submitUpdate({'age': age});
      }
    }
  }

  void updateGender(String value) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: value, // Updated value
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
      _submitUpdate({'gender': value});
    }
  }

  void updateReligion(String value) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: value, // Updated value
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
      _submitUpdate({'religion': value});
    }
  }

  void updateZodiac(String value) {
    if (userProfile.value != null) {
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: value, // Updated value
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: userProfile.value!.lifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
      _submitUpdate({'zodiacSign': value});
    }
  }

  // Lifestyle update methods
  void updateHeight(String value) {
    if (userProfile.value != null && userProfile.value!.lifestyle != null) {
      final oldLifestyle = userProfile.value!.lifestyle!;
      final updatedLifestyle = Lifestyle(
        sleepingStyle: value,  // Using sleepingStyle as placeholder for height
        loveStyle: oldLifestyle.loveStyle,
        weekends: oldLifestyle.weekends,
        traveling: oldLifestyle.traveling,
        homeEnvironment: oldLifestyle.homeEnvironment,
        livingSpace: oldLifestyle.livingSpace,
      );
      
      final updatedProfile = UserProfile(
        id: userProfile.value!.id,
        role: userProfile.value!.role,
        email: userProfile.value!.email,
        age: userProfile.value!.age,
        gender: userProfile.value!.gender,
        firstName: userProfile.value!.firstName,
        lastName: userProfile.value!.lastName,
        aboutMe: userProfile.value!.aboutMe,
        religion: userProfile.value!.religion,
        zodiacSign: userProfile.value!.zodiacSign,
        status: userProfile.value!.status,
        isVerified: userProfile.value!.isVerified,
        profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
        isDeleted: userProfile.value!.isDeleted,
        createdAt: userProfile.value!.createdAt,
        updatedAt: userProfile.value!.updatedAt,
        habits: userProfile.value!.habits,
        interests: userProfile.value!.interests,
        lifestyle: updatedLifestyle,
        likeToMeet: userProfile.value!.likeToMeet,
        personalTraitsInspire: userProfile.value!.personalTraitsInspire,
        image: userProfile.value!.image,
        phone: userProfile.value!.phone,
        relationType: userProfile.value!.relationType,
        location: userProfile.value!.location,
      );
      userProfile.value = updatedProfile;
      _submitUpdate({'lifestyle': {'sleepingStyle': value}});
    }
  }

  void updateWeight(String value) {
    if (userProfile.value != null && userProfile.value!.lifestyle != null) {
      final oldLifestyle = userProfile.value!.lifestyle!;
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
    if (userProfile.value != null && userProfile.value!.lifestyle != null) {
      final oldLifestyle = userProfile.value!.lifestyle!;
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
    if (userProfile.value != null && userProfile.value!.lifestyle != null) {
      final oldLifestyle = userProfile.value!.lifestyle!;
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
    userProfile.value = UserProfile(
      id: userProfile.value!.id,
      role: userProfile.value!.role,
      email: userProfile.value!.email,
      age: userProfile.value!.age,
      gender: userProfile.value!.gender,
      firstName: userProfile.value!.firstName,
      lastName: userProfile.value!.lastName,
      aboutMe: userProfile.value!.aboutMe,
      religion: userProfile.value!.religion,
      zodiacSign: userProfile.value!.zodiacSign,
      status: userProfile.value!.status,
      isVerified: userProfile.value!.isVerified,
      profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
      isDeleted: userProfile.value!.isDeleted,
      createdAt: userProfile.value!.createdAt,
      updatedAt: userProfile.value!.updatedAt,
      habits: userProfile.value!.habits,
      interests: userProfile.value!.interests,
      lifestyle: lifestyle,
      likeToMeet: userProfile.value!.likeToMeet,
      personalTraitsInspire: userProfile.value!.personalTraitsInspire,
      image: userProfile.value!.image,
      phone: userProfile.value!.phone,
      relationType: userProfile.value!.relationType,
      location: userProfile.value!.location,
    );
  }

  // Habits update methods
  void updateCommunicationStyle(String value) {
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    if (userProfile.value != null && userProfile.value!.habits != null) {
      final oldHabits = userProfile.value!.habits!;
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
    userProfile.value = UserProfile(
      id: userProfile.value!.id,
      role: userProfile.value!.role,
      email: userProfile.value!.email,
      age: userProfile.value!.age,
      gender: userProfile.value!.gender,
      firstName: userProfile.value!.firstName,
      lastName: userProfile.value!.lastName,
      aboutMe: userProfile.value!.aboutMe,
      religion: userProfile.value!.religion,
      zodiacSign: userProfile.value!.zodiacSign,
      status: userProfile.value!.status,
      isVerified: userProfile.value!.isVerified,
      profileCompletionPercentage: userProfile.value!.profileCompletionPercentage,
      isDeleted: userProfile.value!.isDeleted,
      createdAt: userProfile.value!.createdAt,
      updatedAt: userProfile.value!.updatedAt,
      habits: habits,
      interests: userProfile.value!.interests,
      lifestyle: userProfile.value!.lifestyle,
      likeToMeet: userProfile.value!.likeToMeet,
      personalTraitsInspire: userProfile.value!.personalTraitsInspire,
      image: userProfile.value!.image,
      phone: userProfile.value!.phone,
      relationType: userProfile.value!.relationType,
      location: userProfile.value!.location,
    );
  }

  // Common lists for dropdowns
  final religions = [
    'Agnostic', 'Atheist', 'Buddhist', 'Christian', 'Hindu',
    'Jewish', 'Muslim', 'Sikh', 'Spiritual', 'Prefer not to say',
  ];

  final zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius',
    'Pisces', 'Not sure', 'Prefer not to say',
  ];

  final communicationStyles = [
    'Good texter', 'Bad texter', 'Video Chatter', 'Phone caller'
  ];

  final exerciseFrequencies = [
    'Yes', 'Several times a week', 'Rarely', 'Never'
  ];

  final foodPreferences = [
    'Healthy and balanced', 'Whatever I feel like', 'Specific diet', "I don't eat"
  ];

  final socialMediaUsage = [
    'Yes', 'Occasionally', 'Frequently', 'Rarely', 'Never'
  ];

  final smokingDrinking = [
    'Yes', 'Occasionally', 'No'
  ];

  final newExperienceOptions = [
    'Absolutely', 'Sometimes', 'Rarely', 'Never'
  ];

  final genders = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say'
  ];

  // Education and Job Status options
  final educationLevels = [
    'High School', 'Some College', 'Associates Degree', "Bachelor's Degree",
    "Master's Degree", 'Doctorate', 'Trade School', 'Prefer not to say'
  ];

  final jobStatuses = [
    'Student', 'Employed Full-time', 'Employed Part-time', 'Self-employed',
    'Freelancer', 'Looking for work', 'Not working', 'Retired', 'Prefer not to say'
  ];

  // Lifestyle options
  final sleepingStyles = [
    'Early bird', 'Night owl', 'Flexible', 'Regular schedule'
  ];

  final loveStyles = [
    'Romantic', 'Practical', 'Passionate', 'Playful', 'Traditional',
    'Modern', 'Independent', 'Affectionate'
  ];

  final weekendStyles = [
    'Active and outdoors', 'Relaxing at home', 'Socializing', 'Mix of everything',
    'Working', 'Hobbies and projects'
  ];

  final travelingStyles = [
    'Love to travel', 'Occasional trips', 'Rarely travel', 'Never travel',
    'Business travel only', 'Adventure seeker'
  ];

  final homeEnvironments = [
    'Neat and organized', 'Comfortably messy', 'Minimalist', 'Cozy and decorated',
    'Practical', 'Always changing'
  ];

  final livingSpaces = [
    'Live alone', 'With roommates', 'With family', 'With partner',
    'Frequently moving', 'Other'
  ];

  // Submit updates to the server
  Future<void> _submitUpdate(Map<String, dynamic> data) async {
    try {
      await _profileService.updateProfile(data: data);
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}