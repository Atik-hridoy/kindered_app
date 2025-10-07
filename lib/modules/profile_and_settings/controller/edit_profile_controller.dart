import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/profile_and_settings/services/profile_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import 'package:kindered_app/modules/profile_and_settings/model/get_profile.dart';

class ProfileEditController extends GetxController {
  late final ProfileService _profileService;
  final ImagePicker _imagePicker = ImagePicker();

  // State management
  final isLoading = RxBool(false);
  final _isInitialized = RxBool(false);
  final Rx<UserProfile?> _userProfile = Rx<UserProfile?>(null);
  final _profileCompletion = RxInt(0);
  final isAboutMeDirty = RxBool(false);
  final isEditMode = RxBool(false);

  // Text editing controllers
  late TextEditingController aboutMeController;
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController educationController;
  late TextEditingController jobStatusController;
  late TextEditingController locationController;

  // Dropdown options
  final List<String> genders = ['Male', 'Female', 'Non-binary', 'Trans man', 'Trans woman', 'Prefer not to say'];
  final List<String> zodiacSigns = ['Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'];
  final List<String> religions = ['Christianity', 'Islam', 'Hinduism', 'Buddhism', 'Judaism', 'Sikhism', 'Spiritual', 'Agnostic', 'Atheist', 'Other'];
  final List<String> sleepingStyles = ['Early bird', 'Night owl', 'Flexible'];
  final List<String> loveStyles = ['Romantic', 'Practical', 'Adventurous', 'Traditional', 'Modern'];
  final List<String> weekendPreferences = ['Homebody', 'Social butterfly', 'Adventure seeker', 'Relaxation focused'];
  final List<String> travelingPreferences = ['Love traveling', 'Prefer staying local', 'Occasional traveler'];
  final List<String> homeEnvironments = ['Cozy', 'Modern', 'Minimalist', 'Traditional', 'Eclectic'];
  final List<String> livingSpaces = ['House', 'Apartment', 'Condo', 'Shared housing'];
  final List<String> communicationStyles = ['Direct', 'Diplomatic', 'Reserved', 'Expressive'];
  final List<String> exerciseFrequencies = ['Daily', '3-4 times/week', '1-2 times/week', 'Occasionally', 'Never'];
  final List<String> foodPreferences = ['Omnivore', 'Vegetarian', 'Vegan', 'Pescatarian', 'Keto', 'Gluten-free'];
  final List<String> socialMediaUsage = ['Very active', 'Moderately active', 'Occasionally', 'Rarely', 'Never'];
  final List<String> smokingDrinking = ['Non-smoker, Non-drinker', 'Social drinker', 'Smoker', 'Both smoker and drinker'];
  final List<String> newExperienceOptions = ['Love trying new things', 'Open to new experiences', 'Prefer familiar things', 'Selective about new experiences'];
  final List<String> educationLevels = ['High School', 'Some College', 'Associates Degree', "Bachelor's Degree", "Master's Degree", 'Doctorate', 'Trade School', 'Other', 'Prefer not to say'];
  final List<String> jobStatuses = ['Student', 'Employed Full-time', 'Employed Part-time', 'Self-employed', 'Freelancer', 'Looking for work', 'Not working', 'Retired', 'Prefer not to say'];

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

  // Aliases
  List<String> get weekendStyles => weekendPreferences;
  List<String> get travelingStyles => travelingPreferences;

  // Getters
  bool get isLoadingValue => isLoading.value;
  bool get isInitialized => _isInitialized.value;
  bool get isProfileServiceInitialized => _isInitialized.value;
  UserProfile? get profile => _userProfile.value;
  int get profileCompletion => _profileCompletion.value;
  int get profileCompletionPercentage => profile?.profileCompletionPercentage ?? 0;
  
  String get userFirstName => profile?.firstName ?? '';
  String get userLastName => profile?.lastName ?? '';
  String get userEmail => profile?.email ?? '';
  String get userAge => profile?.age?.toString() ?? '';
  String get userGender => profile?.gender ?? '';
  String get userAboutMe => profile?.aboutMe ?? '';
  String get userReligion => profile?.religion ?? '';
  String get userZodiacSign => profile?.zodiacSign ?? '';
  String get userHeight => profile?.body?.heightCm?.toString() ?? '';
  String get userWeight => profile?.body?.weightKg?.toString() ?? '';
  String get userSleepingStyle => profile?.lifestyle?.sleepingStyle ?? '';
  String get userLoveStyle => profile?.lifestyle?.loveStyle ?? '';
  String get userWeekend => profile?.lifestyle?.weekends ?? '';
  String get userTravelling => profile?.lifestyle?.traveling ?? '';
  String get userHomeEnvironment => profile?.lifestyle?.homeEnvironment ?? '';
  String get userLivingSpace => profile?.lifestyle?.livingSpace ?? '';
  String get userWorkout => profile?.habits?.workout ?? '';
  String get userSocialMedia => profile?.habits?.socialMedia ?? '';
  String get userSmokeOrDrink => profile?.habits?.smokeOrDrink ?? '';
  String get userNewExperiences => profile?.habits?.newExercise ?? '';
  String get userLocation => profile?.location != null ? 'Location available' : '';
  String get userRelationType => profile?.relationType ?? '';
  
  List<String> get userPhotos => profile?.image ?? [];
  List<String> get userTraits => profile?.personalTraitsInspire ?? [];
  List<String> get userPreferences => profile?.likeToMeet ?? [];
  List<String> get userCommunicationStyle => profile?.habits?.communicationStyle ?? [];
  List<String> get userEatingStyle => profile?.habits?.eatingStyle ?? [];
  
  List<String> get userInterests {
    final interests = profile?.interests;
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

  // Compatibility aliases
  String get location => userLocation;
  String get height => userHeight;
  String get weight => userWeight;
  String get education => userWeekend;
  String get jobStatus => userTravelling;
  String get lookingFor => userRelationType;

  @override
  void onInit() {
    super.onInit();
    _initializeControllers();
    _initializeController();
  }

  void _initializeControllers() {
    aboutMeController = TextEditingController();
    nameController = TextEditingController();
    ageController = TextEditingController();
    heightController = TextEditingController();
    weightController = TextEditingController();
    educationController = TextEditingController();
    jobStatusController = TextEditingController();
    locationController = TextEditingController();
    
    _addControllerListeners();
  }

  void _addControllerListeners() {
    final controllers = [
      nameController,
      ageController,
      heightController,
      weightController,
      educationController,
      jobStatusController,
      locationController
    ];
    
    for (var controller in controllers) {
      controller.addListener(_updateProfileCompletionFromControllers);
    }
  }

  void _initializeController() {
    _initializeProfileService().then((_) {
      if (LocalStorage.token.isNotEmpty && isProfileServiceInitialized) {
        _loadProfileData();
      }
    }).catchError((e) {
      AppLogger.error('Error initializing controller: $e');
    });
  }

  Future<void> _initializeProfileService() async {
    try {
      final token = await LocalStorage.getString(LocalStorageKeys.token);
      
      if (token.isEmpty) {
        _showSnackbar('Authentication Required', 'Please sign in to view your profile.', Colors.red);
        return;
      }
      
      LocalStorage.token = token;
      _profileService = ProfileService(token);
      _isInitialized.value = true;
    } catch (e) {
      AppLogger.error('Error initializing ProfileService: $e');
      rethrow;
    }
  }

  Future<void> _loadProfileData() async {
    if (!isProfileServiceInitialized || LocalStorage.token.isEmpty) return;
    
    isLoading.value = true;
    try {
      final response = await _profileService.getProfile();
      
      if (response.statusCode == 200 && response.data != null) {
        _mapApiDataToController(response.data);
      } else if (response.statusCode == 401) {
        _handleAuthError();
      } else {
        _showSnackbar('Error', 'Failed to fetch profile data (${response.statusCode}). Please try again.', Colors.orange);
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _showSnackbar('Error', 'An unexpected error occurred while fetching profile data.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  void _mapApiDataToController(Map<String, dynamic> data) {
    try {
      final profileData = data['data'] as Map<String, dynamic>;
      final userProfileData = UserProfile.fromJson(profileData);
      
      _userProfile.value = userProfileData;
      _initializeAboutMeController();
      _profileCompletion.value = userProfileData.profileCompletionPercentage;
      
      _verifyProfileData(userProfileData);
    } catch (e) {
      AppLogger.error('Error mapping API data to UserProfile model: $e');
    }
  }

  void _verifyProfileData(UserProfile profile) {
    List<String> missingRequiredFields = [];
    List<String> missingOptionalFields = [];
    
    if (profile.firstName.isEmpty) missingRequiredFields.add('First Name');
    if (profile.age == null) missingRequiredFields.add('Age');
    if (profile.gender.isEmpty) missingRequiredFields.add('Gender');
    
    if (profile.lifestyle != null) {
      final lifestyle = profile.lifestyle!;
      if (lifestyle.sleepingStyle?.isEmpty ?? true) missingOptionalFields.add('Sleeping Style');
      if (lifestyle.loveStyle?.isEmpty ?? true) missingOptionalFields.add('Love Style');
      if (lifestyle.weekends?.isEmpty ?? true) missingOptionalFields.add('Weekend Preference');
      if (lifestyle.traveling?.isEmpty ?? true) missingOptionalFields.add('Travel Preference');
      if (lifestyle.homeEnvironment?.isEmpty ?? true) missingOptionalFields.add('Home Environment');
      if (lifestyle.livingSpace?.isEmpty ?? true) missingOptionalFields.add('Living Space');
    }
    
    if (profile.habits == null) {
      missingRequiredFields.add('Habits Information');
    } else {
      final habits = profile.habits!;
      if (habits.communicationStyle.isEmpty) missingRequiredFields.add('Communication Style');
      if (habits.eatingStyle.isEmpty) missingRequiredFields.add('Eating Style');
      if (habits.workout?.isEmpty ?? true) missingOptionalFields.add('Workout Preference');
      if (habits.socialMedia?.isEmpty ?? true) missingOptionalFields.add('Social Media Usage');
      if (habits.smokeOrDrink?.isEmpty ?? true) missingOptionalFields.add('Smoking/Drinking Preference');
      if (habits.newExercise?.isEmpty ?? true) missingOptionalFields.add('New Experiences');
    }
    
    if (profile.interests == null) {
      missingRequiredFields.add('Interests Information');
    } else {
      final interests = profile.interests!;
      bool hasAnyInterest = interests.hobbies.isNotEmpty ||
          interests.creativeOutlets.isNotEmpty ||
          interests.fitnessAndSports.isNotEmpty ||
          interests.entertainment.isNotEmpty ||
          interests.leisureActivities.isNotEmpty ||
          interests.musicGenres.isNotEmpty ||
          interests.healthAndWellness.isNotEmpty ||
          interests.readingAndContent.isNotEmpty;
      
      if (!hasAnyInterest) missingRequiredFields.add('At least one interest category');
    }
    
    if (profile.likeToMeet.isEmpty) missingRequiredFields.add('Like to Meet Preferences');
    if (profile.personalTraitsInspire.isEmpty) missingRequiredFields.add('Personal Traits');
    if (profile.relationType?.isEmpty ?? true) missingRequiredFields.add('Relation Type');
    if (profile.image.isEmpty) missingOptionalFields.add('Profile Photos');
    
    if (missingRequiredFields.isNotEmpty) {
      _showSnackbar('Required Information Missing', 'Please complete the required profile information to continue.', Colors.red, duration: 5);
    } else if (missingOptionalFields.isNotEmpty) {
      _showSnackbar('Profile Enhancement', 'Consider adding more details to enhance your profile.', Colors.blue, duration: 4);
    }
  }

  void _handleAuthError() {
    _showSnackbar('Session Expired', 'Please refresh the app or login again to continue', Colors.orange, duration: 5);
  }

  void _handleDioError(DioException e) {
    String errorMessage = 'Failed to fetch profile data';
    if (e.response?.statusCode == 401) {
      errorMessage = 'Session expired. Please sign in again.';
      _handleAuthError();
    } else if (e.response?.data != null) {
      errorMessage = e.response?.data['message'] ?? e.response?.data['error'] ?? errorMessage;
    }
    _showSnackbar('Error', errorMessage, Colors.red);
  }

  // Image picking methods
  Future<void> pickImageFromCamera(int index) => _pickImage(ImageSource.camera, index);
  Future<void> pickImageFromGallery(int index) => _pickImage(ImageSource.gallery, index);

  Future<void> _pickImage(ImageSource source, int index) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1000,
        maxHeight: 1000,
      );

      if (pickedFile != null) {
        await _handlePickedImage(pickedFile, index);
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to pick photo. Please try again.', Colors.red);
    }
  }

  Future<void> _handlePickedImage(XFile pickedFile, int index) async {
    if (!isProfileServiceInitialized) return;
    
    isLoading.value = true;
    try {
      final file = File(pickedFile.path);
      final response = await _profileService.updateProfile(data: {}, images: [file]);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadProfileData();
        _showSnackbar('Success', 'Profile photo updated successfully', Colors.green);
      } else {
        throw Exception('Failed to upload image: ${response.statusMessage}');
      }
    } catch (e) {
      _showSnackbar('Error', 'Failed to upload photo. Please try again.', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Edit mode methods
  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (isEditMode.value) {
      _initializeControllersForEdit();
    } else {
      _saveProfileChanges();
    }
  }

  void cancelEditMode() {
    isEditMode.value = false;
    _resetControllersToProfileData();
  }

  void _initializeControllersForEdit() {
    if (profile == null) return;
    
    nameController.text = profile!.firstName ?? '';
    ageController.text = profile!.age?.toString() ?? '';
    heightController.text = profile!.body?.heightCm?.toString() ?? '';
    weightController.text = profile!.body?.weightKg?.toString() ?? '';
    educationController.text = profile!.eduJob?.educationLevel ?? '';
    jobStatusController.text = profile!.eduJob?.jobTitle ?? '';
    locationController.text = profile!.location?.toString() ?? '';
    
    selectedGender.value = profile!.gender ?? '';
    selectedZodiac.value = profile!.zodiacSign ?? '';
    selectedReligion.value = profile!.religion ?? '';
    selectedSleepingStyle.value = profile!.lifestyle?.sleepingStyle ?? '';
    selectedLoveStyle.value = profile!.lifestyle?.loveStyle ?? '';
    selectedWeekends.value = profile!.lifestyle?.weekends ?? '';
    selectedTraveling.value = profile!.lifestyle?.traveling ?? '';
    selectedCommunicationStyle.value = profile!.habits?.communicationStyle.join(', ') ?? '';
    selectedExerciseFrequency.value = profile!.habits?.workout ?? '';
    selectedFoodPreference.value = profile!.habits?.eatingStyle.join(', ') ?? '';
    selectedSocialMediaUsage.value = profile!.habits?.socialMedia ?? '';
    selectedSmokingDrinking.value = profile!.habits?.smokeOrDrink ?? '';
    selectedNewExperiences.value = profile!.habits?.newExercise ?? '';
  }

  void _resetControllersToProfileData() => _initializeControllersForEdit();

  void _updateProfileCompletionFromControllers() {
    updateProfileCompletion();
  }

  Future<void> _saveProfileChanges() async {
    if (profile == null) return;
    
    isLoading.value = true;
    try {
      final changes = _collectProfileChanges();
      
      if (changes.isNotEmpty) {
        await _submitUpdate(changes);
        _showSnackbar('Success', 'Profile updated successfully', Colors.green);
      }
    } catch (e) {
      AppLogger.error('Error saving profile changes: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _collectProfileChanges() {
    final changes = <String, dynamic>{};
    
    if (nameController.text.isNotEmpty && nameController.text != profile!.firstName) {
      changes['firstName'] = nameController.text;
    }
    
    final newAge = int.tryParse(ageController.text);
    if (newAge != null && newAge != profile!.age) {
      changes['age'] = newAge;
    }
    
    if (selectedGender.value.isNotEmpty && selectedGender.value != profile!.gender) {
      changes['gender'] = selectedGender.value;
    }
    
    _addBodyChanges(changes);
    _addBasicChanges(changes);
    _addLifestyleChanges(changes);
    _addHabitsChanges(changes);
    
    return changes;
  }

  void _addBodyChanges(Map<String, dynamic> changes) {
    final newHeight = double.tryParse(heightController.text);
    final newWeight = double.tryParse(weightController.text);
    
    if (newHeight != null && newHeight != profile!.body?.heightCm) {
      changes['body'] = {'heightCm': newHeight};
    }
    
    if (newWeight != null && newWeight != profile!.body?.weightKg) {
      changes['body'] ??= {};
      changes['body']['weightKg'] = newWeight;
    }
  }

  void _addBasicChanges(Map<String, dynamic> changes) {
    if (selectedZodiac.value.isNotEmpty && selectedZodiac.value != profile!.zodiacSign) {
      changes['zodiacSign'] = selectedZodiac.value;
    }
    
    if (selectedReligion.value.isNotEmpty && selectedReligion.value != profile!.religion) {
      changes['religion'] = selectedReligion.value;
    }
  }

  void _addLifestyleChanges(Map<String, dynamic> changes) {
    final lifestyleUpdates = <String, String>{
      'sleepingStyle': selectedSleepingStyle.value,
      'loveStyle': selectedLoveStyle.value,
      'weekends': selectedWeekends.value,
      'traveling': selectedTraveling.value,
      'homeEnvironment': selectedHomeEnvironment.value,
      'livingSpace': selectedLivingSpace.value,
    };
    
    lifestyleUpdates.forEach((key, value) {
      if (value.isNotEmpty && value != _getLifestyleValue(key)) {
        changes['lifestyle'] ??= {};
        changes['lifestyle'][key] = value;
      }
    });
  }

  String _getLifestyleValue(String key) {
    final lifestyle = profile!.lifestyle;
    if (lifestyle == null) return '';
    
    switch (key) {
      case 'sleepingStyle': return lifestyle.sleepingStyle ?? '';
      case 'loveStyle': return lifestyle.loveStyle ?? '';
      case 'weekends': return lifestyle.weekends ?? '';
      case 'traveling': return lifestyle.traveling ?? '';
      case 'homeEnvironment': return lifestyle.homeEnvironment ?? '';
      case 'livingSpace': return lifestyle.livingSpace ?? '';
      default: return '';
    }
  }

  void _addHabitsChanges(Map<String, dynamic> changes) {
    if (selectedCommunicationStyle.value.isNotEmpty && 
        selectedCommunicationStyle.value != profile!.habits?.communicationStyle.join(', ')) {
      changes['habits'] ??= {};
      changes['habits']['communicationStyle'] = selectedCommunicationStyle.value.split(', ').map((s) => s.trim()).toList();
    }
    
    if (selectedExerciseFrequency.value.isNotEmpty && 
        selectedExerciseFrequency.value != profile!.habits?.workout) {
      changes['habits'] ??= {};
      changes['habits']['workout'] = selectedExerciseFrequency.value;
    }
    
    if (selectedFoodPreference.value.isNotEmpty && 
        selectedFoodPreference.value != profile!.habits?.eatingStyle.join(', ')) {
      changes['habits'] ??= {};
      changes['habits']['eatingStyle'] = selectedFoodPreference.value.split(', ').map((s) => s.trim()).toList();
    }
    
    if (selectedSocialMediaUsage.value.isNotEmpty && 
        selectedSocialMediaUsage.value != profile!.habits?.socialMedia) {
      changes['habits'] ??= {};
      changes['habits']['socialMedia'] = selectedSocialMediaUsage.value;
    }
    
    if (selectedSmokingDrinking.value.isNotEmpty && 
        selectedSmokingDrinking.value != profile!.habits?.smokeOrDrink) {
      changes['habits'] ??= {};
      changes['habits']['smokeOrDrink'] = selectedSmokingDrinking.value;
    }
    
    if (selectedNewExperiences.value.isNotEmpty && 
        selectedNewExperiences.value != profile!.habits?.newExercise) {
      changes['habits'] ??= {};
      changes['habits']['newExercise'] = selectedNewExperiences.value;
    }
  }

  Future<void> _submitUpdate(Map<String, dynamic> data) async {
    if (!isProfileServiceInitialized) return;

    try {
      final response = await _profileService.updateProfile(data: data);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        await _loadProfileData();
        _showSnackbar('Success', 'Profile updated successfully', Colors.green);
      } else {
        throw Exception('Failed to update profile: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _showSnackbar('Error', 'An unexpected error occurred while updating profile.', Colors.red);
    }
  }

  // Profile update methods
  void updateProfileCompletion() {
    _profileCompletion.value = profileCompletionPercentage;
  }

  void addPhoto(String photoUrl) {
    if (profile != null && profile!.image.length < 6) {
      final currentPhotos = List<String>.from(profile!.image)..add(photoUrl);
      _updateProfile(image: currentPhotos);
    }
  }

  void removePhoto(int index) {
    if (profile != null && index >= 0 && index < profile!.image.length) {
      final currentPhotos = List<String>.from(profile!.image)..removeAt(index);
      _updateProfile(image: currentPhotos);
    }
  }

  void toggleTrait(String trait) {
    if (profile != null) {
      final currentTraits = List<String>.from(profile!.personalTraitsInspire);
      if (currentTraits.contains(trait)) {
        currentTraits.remove(trait);
      } else {
        currentTraits.add(trait);
      }
      _updateProfile(personalTraitsInspire: currentTraits);
    }
  }

  void toggleInterest(String interest) {
    // Placeholder for complex interest toggling logic
  }

  void updateAboutMe(String value) {
    aboutMeController.text = value;
    isAboutMeDirty.value = true;
  }

  Future<void> submitAboutMe() async {
    if (!isAboutMeDirty.value || profile == null) return;
    
    _updateProfile(aboutMe: aboutMeController.text);
    isAboutMeDirty.value = false;
  }

  void _initializeAboutMeController() {
    if (profile != null) {
      aboutMeController.text = profile!.aboutMe ?? '';
      isAboutMeDirty.value = false;
    }
  }

  Future<void> refreshProfileData() => _loadProfileData();

  // Individual field update methods
  void updateName(String value) => _updateProfile(firstName: value);
  void updateAge(String value) => _updateProfile(age: int.tryParse(value));
  void updateGender(String value) => _updateProfile(gender: value);
  void updateReligion(String value) => _updateProfile(religion: value);
  void updateZodiac(String value) => _updateProfile(zodiacSign: value);
  void updateHeight(String value) => _updateBody(heightCm: double.tryParse(value));
  void updateWeight(String value) => _updateBody(weightKg: double.tryParse(value));

  Future<void> updateBasicProfileInfo() async {
    if (profile == null) {
      _showSnackbar('Error', 'No profile data available', Colors.red);
      return;
    }

    if (nameController.text.isEmpty || ageController.text.isEmpty || selectedGender.value.isEmpty) {
      _showSnackbar('Required Field', 'Name, age, and gender are required', Colors.orange);
      return;
    }

    isLoading.value = true;
    try {
      if (nameController.text != profile!.firstName) updateName(nameController.text);
      
      final newAge = int.tryParse(ageController.text);
      if (newAge != null && newAge != profile!.age) updateAge(ageController.text);
      
      if (selectedGender.value != profile!.gender) updateGender(selectedGender.value);
      if (heightController.text.isNotEmpty && heightController.text != userHeight) updateHeight(heightController.text);
      if (weightController.text.isNotEmpty && weightController.text != userWeight) updateWeight(weightController.text);

      _showSnackbar('Success', 'Profile information updated successfully', Colors.green);
    } catch (e) {
      _showSnackbar('Error', 'An unexpected error occurred while updating profile', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  // Habits update methods
  void updateCommunicationStyle(String value) => _updateHabits(communicationStyle: [value]);
  void updateWorkout(String value) => _updateHabits(workout: value);
  void updateEatingStyle(String value) => _updateHabits(eatingStyle: [value]);
  void updateSocialMedia(String value) => _updateHabits(socialMedia: value);
  void updateSmokeOrDrink(String value) => _updateHabits(smokeOrDrink: value);
  void updateNewExperiences(String value) => _updateHabits(newExercise: value);

  // Lifestyle update methods
  void updateSleepingStyle(String value) => _updateLifestyle(sleepingStyle: value);
  void updateLoveStyle(String value) => _updateLifestyle(loveStyle: value);
  void updateWeekend(String value) => _updateLifestyle(weekends: value);
  void updateTravelling(String value) => _updateLifestyle(traveling: value);
  void updateHomeEnvironment(String value) => _updateLifestyle(homeEnvironment: value);
  void updateLivingSpace(String value) => _updateLifestyle(livingSpace: value);

  // Education and Career update methods
  void updateEducation(String value) {
    // Placeholder for education update logic
  }

  void updateJobStatus(String value) {
    // Placeholder for job status update logic
  }

  // Helper methods for profile updates
  void _updateProfile({
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    String? aboutMe,
    String? religion,
    String? zodiacSign,
    List<String>? image,
    List<String>? personalTraitsInspire,
  }) {
    if (profile == null) return;
    
    _userProfile.value = UserProfile(
      id: profile!.id,
      role: profile!.role,
      email: profile!.email,
      age: age ?? profile!.age,
      gender: gender ?? profile!.gender,
      firstName: firstName ?? profile!.firstName,
      lastName: lastName ?? profile!.lastName,
      aboutMe: aboutMe ?? profile!.aboutMe,
      religion: religion ?? profile!.religion,
      zodiacSign: zodiacSign ?? profile!.zodiacSign,
      status: profile!.status,
      profileCompletionPercentage: profile!.profileCompletionPercentage,
      isDeleted: profile!.isDeleted,
      isVerified: profile!.isVerified,
      createdAt: profile!.createdAt,
      updatedAt: profile!.updatedAt,
      habits: profile!.habits,
      interests: profile!.interests,
      lifestyle: profile!.lifestyle,
      likeToMeet: profile!.likeToMeet,
      personalTraitsInspire: personalTraitsInspire ?? profile!.personalTraitsInspire,
      image: image ?? profile!.image,
      bodyImage: profile!.bodyImage,
      headShotImage: profile!.headShotImage,
      personalityImage: profile!.personalityImage,
      phone: profile!.phone,
      relationType: profile!.relationType,
      location: profile!.location,
      body: profile!.body,
      eduJob: profile!.eduJob,
      beliefsOtherText: profile!.beliefsOtherText,
      address: profile!.address,
      traitsOtherText: profile!.traitsOtherText,
    );
  }

  void _updateBody({double? heightCm, double? weightKg}) {
    if (profile == null) return;
    
    final updatedBody = Body(
      heightCm: heightCm ?? profile!.body?.heightCm,
      weightKg: weightKg ?? profile!.body?.weightKg,
    );
    
    _userProfile.value = UserProfile(
      id: profile!.id,
      role: profile!.role,
      email: profile!.email,
      age: profile!.age,
      gender: profile!.gender,
      firstName: profile!.firstName,
      lastName: profile!.lastName,
      aboutMe: profile!.aboutMe,
      religion: profile!.religion,
      zodiacSign: profile!.zodiacSign,
      status: profile!.status,
      profileCompletionPercentage: profile!.profileCompletionPercentage,
      isDeleted: profile!.isDeleted,
      isVerified: profile!.isVerified,
      createdAt: profile!.createdAt,
      updatedAt: profile!.updatedAt,
      habits: profile!.habits,
      interests: profile!.interests,
      lifestyle: profile!.lifestyle,
      likeToMeet: profile!.likeToMeet,
      personalTraitsInspire: profile!.personalTraitsInspire,
      image: profile!.image,
      bodyImage: profile!.bodyImage,
      headShotImage: profile!.headShotImage,
      personalityImage: profile!.personalityImage,
      phone: profile!.phone,
      relationType: profile!.relationType,
      location: profile!.location,
      body: updatedBody,
      eduJob: profile!.eduJob,
      beliefsOtherText: profile!.beliefsOtherText,
      address: profile!.address,
      traitsOtherText: profile!.traitsOtherText,
    );
  }

  void _updateLifestyle({
    String? sleepingStyle,
    String? loveStyle,
    String? weekends,
    String? traveling,
    String? homeEnvironment,
    String? livingSpace,
  }) {
    if (profile == null || profile!.lifestyle == null) return;
    
    final updatedLifestyle = Lifestyle(
      sleepingStyle: sleepingStyle ?? profile!.lifestyle!.sleepingStyle,
      loveStyle: loveStyle ?? profile!.lifestyle!.loveStyle,
      weekends: weekends ?? profile!.lifestyle!.weekends,
      traveling: traveling ?? profile!.lifestyle!.traveling,
      homeEnvironment: homeEnvironment ?? profile!.lifestyle!.homeEnvironment,
      livingSpace: livingSpace ?? profile!.lifestyle!.livingSpace,
    );
    
    _userProfile.value = UserProfile(
      id: profile!.id,
      role: profile!.role,
      email: profile!.email,
      age: profile!.age,
      gender: profile!.gender,
      firstName: profile!.firstName,
      lastName: profile!.lastName,
      aboutMe: profile!.aboutMe,
      religion: profile!.religion,
      zodiacSign: profile!.zodiacSign,
      status: profile!.status,
      profileCompletionPercentage: profile!.profileCompletionPercentage,
      isDeleted: profile!.isDeleted,
      isVerified: profile!.isVerified,
      createdAt: profile!.createdAt,
      updatedAt: profile!.updatedAt,
      habits: profile!.habits,
      interests: profile!.interests,
      lifestyle: updatedLifestyle,
      likeToMeet: profile!.likeToMeet,
      personalTraitsInspire: profile!.personalTraitsInspire,
      image: profile!.image,
      bodyImage: profile!.bodyImage,
      headShotImage: profile!.headShotImage,
      personalityImage: profile!.personalityImage,
      phone: profile!.phone,
      relationType: profile!.relationType,
      location: profile!.location,
      body: profile!.body,
      eduJob: profile!.eduJob,
      beliefsOtherText: profile!.beliefsOtherText,
      address: profile!.address,
      traitsOtherText: profile!.traitsOtherText,
    );
  }

  void _updateHabits({
    List<String>? communicationStyle,
    String? workout,
    List<String>? eatingStyle,
    String? socialMedia,
    String? smokeOrDrink,
    String? newExercise,
  }) {
    if (profile == null || profile!.habits == null) return;
    
    final updatedHabits = Habits(
      communicationStyle: communicationStyle ?? profile!.habits!.communicationStyle,
      workout: workout ?? profile!.habits!.workout,
      eatingStyle: eatingStyle ?? profile!.habits!.eatingStyle,
      socialMedia: socialMedia ?? profile!.habits!.socialMedia,
      smokeOrDrink: smokeOrDrink ?? profile!.habits!.smokeOrDrink,
      newExercise: newExercise ?? profile!.habits!.newExercise,
    );
    
    _userProfile.value = UserProfile(
      id: profile!.id,
      role: profile!.role,
      email: profile!.email,
      age: profile!.age,
      gender: profile!.gender,
      firstName: profile!.firstName,
      lastName: profile!.lastName,
      aboutMe: profile!.aboutMe,
      religion: profile!.religion,
      zodiacSign: profile!.zodiacSign,
      status: profile!.status,
      profileCompletionPercentage: profile!.profileCompletionPercentage,
      isDeleted: profile!.isDeleted,
      isVerified: profile!.isVerified,
      createdAt: profile!.createdAt,
      updatedAt: profile!.updatedAt,
      habits: updatedHabits,
      interests: profile!.interests,
      lifestyle: profile!.lifestyle,
      likeToMeet: profile!.likeToMeet,
      personalTraitsInspire: profile!.personalTraitsInspire,
      image: profile!.image,
      bodyImage: profile!.bodyImage,
      headShotImage: profile!.headShotImage,
      personalityImage: profile!.personalityImage,
      phone: profile!.phone,
      relationType: profile!.relationType,
      location: profile!.location,
      body: profile!.body,
      eduJob: profile!.eduJob,
      beliefsOtherText: profile!.beliefsOtherText,
      address: profile!.address,
      traitsOtherText: profile!.traitsOtherText,
    );
  }

  // Utility method for showing snackbars
  void _showSnackbar(String title, String message, Color backgroundColor, {int duration = 3}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      duration: Duration(seconds: duration),
    );
  }
}