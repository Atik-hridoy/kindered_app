import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:kindered_app/config/app_routes.dart';
import '../services/account_setup_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../model/complete_profile.dart';

class AccountsController extends GetxController {
  // Service instance
  late AccountSetupService _accountSetupService;

  // Loading state
  final RxBool isLoading = false.obs;

  // Profile completion percentage
  final RxInt profileCompletionPercentage = 0.obs;

  // =========================================
  // REUSABLE HELPER METHODS
  // =========================================

  /// Generic API call handler with common error handling and response processing
  Future<Map<String, dynamic>> _handleApiCall(
    String methodName,
    Future<dio.Response> Function() apiCall, {
    bool showSuccessSnackbar = true,
    String? successMessage,
    bool checkVerificationStatus = false,
    bool navigateOnSuccess = false,
    String? navigationRoute,
  }) async {
    try {
      isLoading.value = true;

      final response = await apiCall();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        
        // Check for verification status changes if requested
        if (checkVerificationStatus && result['message'] != null) {
          _handleVerificationStatus(result['message'].toString());
        }

        if (result['success'] == true) {
          
          if (showSuccessSnackbar) {
            Get.snackbar(
              'Success',
              successMessage ?? '$methodName completed successfully!',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
          
          // Navigate if requested
          if (navigateOnSuccess && navigationRoute != null) {
            Get.offAllNamed(navigationRoute);
          }
        } else {
          Get.snackbar(
            'Error',
            result['message'] ?? '$methodName failed',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        
        return result;
      } else {
        final errorMessage = 'Failed to complete $methodName: ${response.statusCode}';
        Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      final errorMessage = 'Exception during $methodName: $e';
      Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
      return {'success': false, 'message': errorMessage};
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle verification status detection and display appropriate message
  void _handleVerificationStatus(String message) {
    if (message.contains('not verified') || message.contains('verification')) {
      
      Get.snackbar(
        'Verification Required',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }


  /// Handle file operations for image uploads
  void _logImagePreparation(String operation, Map<String, String?> imagePaths) {
    // Method kept for compatibility but logging removed
  }

  /// Validate image files exist before upload
  Future<bool> _validateImageFiles(Map<String, File?> images) async {
    for (final entry in images.entries) {
      if (entry.value == null || !await entry.value!.exists()) {
        return false;
      }
    }
    return true;
  }

  // =========================================
  // PERSONAL INFO SECTION (from IntroViewController)
  // =========================================
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString age = ''.obs;
  // Persistent controllers to avoid recreating in the view
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  void updateFirstName(String value) {
    firstName.value = value;
    updateProfileCompletion();
  }
  
  void updateLastName(String value) {
    lastName.value = value;
    updateProfileCompletion();
  }
  
  void updateAge(String value) {
    age.value = value;
    updateProfileCompletion();
  }

  void loadUserData() {
    firstName.value = '';
    lastName.value = '';
    age.value = '';
    // Keep text controllers in sync
    firstNameController.text = firstName.value;
    lastNameController.text = lastName.value;
    ageController.text = age.value;
  }

  // =========================================
  // PROFILE DATA BUILDING METHODS
  // =========================================

  /// Build body data according to CompleteProfile model
  Map<String, dynamic> _buildBodyData() {
    int height = int.tryParse(heightController.text.trim()) ?? 0;
    // Ensure height doesn't exceed maximum allowed value (300cm)
    if (height > 300) {
      height = 300;
    }
    
    return {
      'heightCm': height,
      'weightKg': int.tryParse(weightController.text.trim()) ?? 0,
    };
  }

  /// Build education/job data according to CompleteProfile model
  Map<String, dynamic> _buildEduJobData() {
    final educationData = getEducationFormData();
    return {
      'educationLevel': _mapEducationLevel(educationData['education'] ?? ''),
      'jobTitle': educationData['jobStatus'] ?? '',
      'annualIncome': int.tryParse(incomeController.text.trim()) ?? 0,
    };
  }

  /// Build lifestyle data according to CompleteProfile model
  Map<String, dynamic> _buildLifestyleData() {
    return {
      'sleepingStyle': selectedDayPreference.value != null ? dayPreferences[selectedDayPreference.value!] : '',
      'loveStyle': selectedLoveLanguage.value != null ? loveLanguages[selectedLoveLanguage.value!] : '',
      'weekends': selectedWeekendActivity.value != null ? weekendActivities[selectedWeekendActivity.value!] : '',
      'traveling': selectedTravelPreference.value != null ? travelPreferences[selectedTravelPreference.value!] : '',
      'homeEnvironment': selectedHomeEnvironment.value != null ? homeEnvironments[selectedHomeEnvironment.value!] : '',
      'livingSpace': selectedLivingSpace.value != null ? livingSpaces[selectedLivingSpace.value!] : '',
    };
  }

  /// Build habits data according to CompleteProfile model
  Map<String, dynamic> _buildHabitsData() {
    return {
      'communicationStyle': selectedCommunicationStyle.value != null ? [communicationStyles[selectedCommunicationStyle.value!]] : <String>[],
      'workout': selectedExerciseFrequency.value != null ? exerciseFrequencies[selectedExerciseFrequency.value!] : '',
      'eatingStyle': selectedFoodPreference.value != null ? [foodPreferences[selectedFoodPreference.value!]] : <String>[],
      'socialMedia': selectedSocialMediaUsage.value != null ? socialMediaUsage[selectedSocialMediaUsage.value!] : '',
      'smokeOrDrink': selectedSmokingDrinking.value != null ? smokingDrinking[selectedSmokingDrinking.value!] : '',
      'newExercise': selectedTryNewExperiences.value != null ? tryNewExperiences[selectedTryNewExperiences.value!] : '',
    };
  }

  /// Build interests data according to CompleteProfile model
  Map<String, List<String>> _buildInterestsData() {
    final Map<String, List<String>> interestsData = {
      'hobbies': <String>[],
      'creativeOutlets': <String>[],
      'fitnessAndSports': <String>[],
      'entertainment': <String>[],
      'leisureActivities': <String>[],
      'musicGenres': <String>[],
      'healthAndWellness': <String>[],
      'readingAndContent': <String>[],
    };

    // Add selected interests to appropriate categories based on selection
    if (selectedInterestIndices.isNotEmpty) {
      for (final index in selectedInterestIndices) {
        final interestTitle = interestOptions[index]['title'] ?? '';
        // Categorize interests based on their titles
        if (interestTitle.toLowerCase().contains('long-term')) {
          interestsData['leisureActivities']?.add(interestTitle);
        } else if (interestTitle.toLowerCase().contains('casual')) {
          interestsData['entertainment']?.add(interestTitle);
        } else if (interestTitle.toLowerCase().contains('bff') || interestTitle.toLowerCase().contains('friend')) {
          interestsData['hobbies']?.add(interestTitle);
        }
      }
    }

    return interestsData;
  }

  /// Build like-to-do data according to CompleteProfile model structure
  Map<String, List<String>> _buildLikeToDoData() {
    final Map<String, List<String>> likeToDoData = {
      'hobbies': <String>[],
      'creativeOutlets': <String>[],
      'fitnessAndSports': <String>[],
      'entertainment': <String>[],
      'leisureActivities': <String>[],
      'musicGenres': <String>[],
      'healthAndWellness': <String>[],
      'readingAndContent': <String>[],
    };

    selectedLikeToDoOptions.forEach((category, indices) {
      if (indices.isNotEmpty) {
        final activities = indices.map((i) => likeToDoOptions[category]![i]).toList();
        // Map categories to the model structure
        switch (category) {
          case 'creativity':
            likeToDoData['creativeOutlets'] = activities;
            break;
          case 'activities':
            likeToDoData['hobbies'] = activities;
            break;
          case 'sportsFitness':
            likeToDoData['fitnessAndSports'] = activities;
            break;
          case 'tvMovies':
            likeToDoData['entertainment'] = activities;
            break;
          case 'freeTime':
            likeToDoData['leisureActivities'] = activities;
            break;
          case 'music':
            likeToDoData['musicGenres'] = activities;
            break;
          case 'wellnessLifestyle':
            likeToDoData['healthAndWellness'] = activities;
            break;
          case 'booksContent':
            likeToDoData['readingAndContent'] = activities;
            break;
        }
      }
    });

    return likeToDoData;
  }

  /// Build complete profile payload using structured data according to CompleteProfile model
  Map<String, dynamic> _prepareCompleteProfileData({bool includeImageFields = false}) {
    // Basic personal info
    final String relationType = selectedInterestIndices.isNotEmpty
        ? interestOptions[selectedInterestIndices.first]['title'] ?? ''
        : '';

    final List<String> likeToMeet = selectedGenders.isNotEmpty ? selectedGenders.toList() : <String>[];

    // Build structured data sections
    final Map<String, dynamic> body = _buildBodyData();
    final Map<String, dynamic> eduJob = _buildEduJobData();
    final Map<String, dynamic> lifestyle = _buildLifestyleData();
    final Map<String, dynamic> habitsPayload = _buildHabitsData();
    final Map<String, List<String>> interestsPayload = _buildInterestsData();
    final Map<String, List<String>> likeToDoPayload = _buildLikeToDoData();

    // Combine interests and like-to-do into a single interests structure
    final Map<String, dynamic> combinedInterests = {
      ...interestsPayload,
      ...likeToDoPayload,
    };

    // Traits/inspire
    final List<String> personalTraitsInspire = selectedTraitIndices.map((i) => traits[i]).toList();

    final Map<String, dynamic> payload = {
      'email': _str(LocalStorage.myEmail),
      'firstName': _str(firstName.value),
      'lastName': _str(lastName.value),
      'phone': _str(LocalStorage.phone),
      'age': _int(age.value),
      'gender': _str(selectedGender.value),
      'relationType': relationType,
      'religion': _str(selectedReligion),
      'zodiacSign': _str(selectedZodiac),
      'likeToMeet': likeToMeet,
      'personalTraitsInspire': personalTraitsInspire,
      'body': body,
      'eduJob': eduJob,
      'lifestyle': lifestyle,
      'habits': habitsPayload,
      'interests': combinedInterests,
      'beliefsOtherText': '',
      'address': _str(LocalStorage.myAddress),
      'traitsOtherText': '',
      'aboutMe': '',
      'location': {
        'coordinates': [0.0, 0.0], // Default coordinates, should be updated with actual location
        'type': 'Point',
      },
      'role': 'USER', // Default role
      'status': 'active', // Default status
      // Note: Removed 'isVerified' field to prevent overriding existing verification status
      'profileCompletionPercentage': getCompletionPercentage(),
      'isDeleted': false, // Default deletion status
    };

    // Only include image fields when explicitly requested (for non-multipart requests)
    if (includeImageFields) {
      payload.addAll({
        'bodyImage': '',
        'headShotImage': '',
        'personalityImage': '',
        'image': <String>[],
      });
    }

    return payload;
  }

  // Helper methods
  
  // Valid education level enum values
  final List<String> validEducationLevels = [
    'High School',
    'Associate',
    'Bachelors', 
    'Masters',
    'PhD',
    'Diploma',
    'Other'
  ];

  /// Map education level text to valid enum values
  String _mapEducationLevel(String educationText) {
    final normalizedText = educationText.toLowerCase().trim();
    
    // Map common education level inputs to valid enum values
    switch (normalizedText) {
      case 'high school':
      case 'highschool':
      case 'secondary':
      case 'secondary school':
        return 'High School';
      case 'college':
      case 'associate':
      case 'associate degree':
      case 'associates':
      case 'associate\'s':
      case 'associate\'s degree':
        return 'Associate';
      case 'bachelor':
      case 'bachelor\'s':
      case 'bachelor\'s degree':
      case 'undergraduate':
      case 'bachelors':
        return 'Bachelors';
      case 'master':
      case 'master\'s':
      case 'master\'s degree':
      case 'graduate':
      case 'masters':
        return 'Masters';
      case 'phd':
      case 'doctorate':
      case 'doctoral':
      case 'doctor':
      case 'doctor\'s':
      case 'doctor\'s degree':
        return 'PhD';
      case 'diploma':
      case 'certificate':
      case 'certification':
        return 'Diploma';
      default:
        // If no match found, return 'Other' as fallback
        return 'Other';
    }
  }
  String _str(String? v) => (v ?? '').trim();
  int _int(String? v) => int.tryParse((v ?? '').trim()) ?? 0;

  /// Submit complete profile with optional photos
  Future<Map<String, dynamic>> submitCompleteProfileWithPhotos(List<String> photoPaths) async {
    _ensureService();

    final profileData = _prepareCompleteProfileData(includeImageFields: false);

    // Convert to File list for the service
    final files = photoPaths.where((p) => p.isNotEmpty).map((p) => File(p)).toList();

    // Map first three images to named fields per backend: bodyImage, headShotImage, personalityImage
    File? bodyImage;
    File? headShotImage;
    File? personalityImage;
    final extraImages = <File>[];
    if (files.isNotEmpty) bodyImage = files[0];
    if (files.length > 1) headShotImage = files[1];
    if (files.length > 2) personalityImage = files[2];
    if (files.length > 3) extraImages.addAll(files.sublist(3));

    // Log image mapping using helper function
    _logImagePreparation('IMAGE MAPPING', {
      'bodyImage': bodyImage?.path,
      'headShotImage': headShotImage?.path,
      'personalityImage': personalityImage?.path,
    });

    // Validate image files before upload
    final imageFiles = {
      'bodyImage': bodyImage,
      'headShotImage': headShotImage,
      'personalityImage': personalityImage,
    };
    
    if (!await _validateImageFiles(imageFiles)) {
      return {'success': false, 'message': 'Some image files are missing or invalid'};
    }

    // Use the helper function for API call
    return _handleApiCall(
      'Profile submission with photos',
      () => _accountSetupService.completeProfileMultipart(
        data: profileData,
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
        extraImages: extraImages,
      ),
      successMessage: 'Profile submitted successfully!',
      checkVerificationStatus: true,
      navigateOnSuccess: true,
      navigationRoute: AppRoutes.locationView,
    );
  }

  /// Submit complete profile data using CompleteProfile model
  Future<Map<String, dynamic>> submitCompleteProfileUsingModel() async {
    _ensureService();

    // Create CompleteProfile instance using current controller data
    final completeProfile = _createCompleteProfileInstance();
    
    // Use the model's toJson() method to get properly structured data
    final profileData = completeProfile.toJson();

    // Use the helper function for API call
    return _handleApiCall(
      'Profile submission using CompleteProfile model',
      () => _accountSetupService.completeProfile(data: profileData),
      successMessage: 'Profile submitted successfully!',
      checkVerificationStatus: true,
      navigateOnSuccess: true,
      navigationRoute: AppRoutes.locationView,
    );
  }

  /// Create a CompleteProfile instance from current controller data
  CompleteProfile _createCompleteProfileInstance() {
    // Build structured data sections
    final Map<String, dynamic> bodyData = _buildBodyData();
    final Map<String, dynamic> eduJobData = _buildEduJobData();
    final Map<String, dynamic> lifestyleData = _buildLifestyleData();
    final Map<String, dynamic> habitsData = _buildHabitsData();
    final Map<String, List<String>> interestsData = _buildInterestsData();
    final Map<String, List<String>> likeToDoData = _buildLikeToDoData();

    // Combine interests and like-to-do into a single interests structure
    final Map<String, List<String>> combinedInterests = {
      ...interestsData,
      ...likeToDoData,
    };

    // Remove freeTime field as it doesn't exist in Interests model
    combinedInterests.remove('freeTime');

    // Basic personal info
    final String relationType = selectedInterestIndices.isNotEmpty
        ? interestOptions[selectedInterestIndices.first]['title'] ?? ''
        : '';

    final List<String> likeToMeet = selectedGenders.isNotEmpty ? selectedGenders.toList() : <String>[];
    final List<String> personalTraitsInspire = selectedTraitIndices.map((i) => traits[i]).toList();

    return CompleteProfile(
      id: '', // Will be generated by backend
      role: 'user',
      email: _str(LocalStorage.myEmail),
      age: _int(age.value),
      gender: _str(selectedGender.value),
      bodyImage: '', // Will be uploaded separately
      headShotImage: '', // Will be uploaded separately
      personalityImage: '', // Will be uploaded separately
      image: null, // Nullable field, will be uploaded separately
      likeToMeet: likeToMeet,
      personalTraitsInspire: personalTraitsInspire,
      address: _str(LocalStorage.myAddress),
      status: 'active',

      profileCompletionPercentage: getCompletionPercentage(),
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      aboutMe: '',
      beliefsOtherText: '',
      body: Body(
        heightCm: bodyData['heightCm'] ?? 0,
        weightKg: bodyData['weightKg'] ?? 0,
      ),
      eduJob: EduJob(
        educationLevel: eduJobData['educationLevel'] ?? '',
        jobTitle: eduJobData['jobTitle'] ?? '',
        annualIncome: eduJobData['annualIncome'] ?? 0,
      ),
      firstName: _str(firstName.value),
      habits: Habits(
        communicationStyle: habitsData['communicationStyle'] ?? <String>[],
        workout: habitsData['workout'] ?? '',
        eatingStyle: habitsData['eatingStyle'] ?? <String>[],
        socialMedia: habitsData['socialMedia'] ?? '',
        smokeOrDrink: habitsData['smokeOrDrink'] ?? '',
        newExercise: habitsData['newExercise'] ?? '',
      ),
      interests: Interests(
        hobbies: combinedInterests['hobbies'] ?? <String>[],
        creativeOutlets: combinedInterests['creativeOutlets'] ?? <String>[],
        fitnessAndSports: combinedInterests['fitnessAndSports'] ?? <String>[],
        entertainment: combinedInterests['entertainment'] ?? <String>[],
        leisureActivities: combinedInterests['leisureActivities'] ?? <String>[],
        musicGenres: combinedInterests['musicGenres'] ?? <String>[],
        healthAndWellness: combinedInterests['healthAndWellness'] ?? <String>[],
        readingAndContent: combinedInterests['readingAndContent'] ?? <String>[],
      ),
      lastName: _str(lastName.value),
      lifestyle: Lifestyle(
        sleepingStyle: lifestyleData['sleepingStyle'] ?? '',
        loveStyle: lifestyleData['loveStyle'] ?? '',
        weekends: lifestyleData['weekends'] ?? '',
        traveling: lifestyleData['traveling'] ?? '',
        homeEnvironment: lifestyleData['homeEnvironment'] ?? '',
        livingSpace: lifestyleData['livingSpace'] ?? '',
      ),
      phone: _str(LocalStorage.phone),
      relationType: relationType,
      religion: _str(selectedReligion),
      traitsOtherText: '',
      zodiacSign: _str(selectedZodiac),
      location: Location(
        coordinates: [0.0, 0.0], // Default coordinates, should be updated with actual location
        type: 'Point',
      ),
    );
  }

  // =========================================
  // GENDER SELECTION SECTION (from GenderViewController)
  // =========================================
  final RxString selectedGender = ''.obs;

  bool get isGenderSelected => selectedGender.value.isNotEmpty;

  void selectGender(String gender) {
    selectedGender.value = gender;
    updateProfileCompletion();
  }

  String? validateGender() {
    if (selectedGender.value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  // =========================================
  // CHOICE SELECTION SECTION (from ChoiceViewController)
  // =========================================
  final RxList<String> selectedGenders = <String>[].obs;

  void toggleGender(String gender) {
    if (selectedGenders.contains(gender)) {
      selectedGenders.remove(gender);
    } else {
      selectedGenders.add(gender);
    }
    updateProfileCompletion();
  }

  bool isGenderSelectedInList(String gender) => selectedGenders.contains(gender);

  void clearGenderSelections() => selectedGenders.clear();

  String? validateGenderSelections() {
    if (selectedGenders.isEmpty) {
      return 'Please select at least one option.';
    }
    return null;
  }

  // =========================================
  // HEIGHT & WEIGHT SECTION (from HeightWeightController)
  // =========================================
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final isHeightValid = false.obs;
  final isWeightValid = false.obs;

  void validateHeightWeightInputs() {
    isHeightValid.value = heightController.text.trim().isNotEmpty;
    isWeightValid.value = weightController.text.trim().isNotEmpty;
    updateProfileCompletion();
  }

  bool get areHeightWeightValid => isHeightValid.value && isWeightValid.value;

  // =========================================
  // EDUCATION & CAREER SECTION (from EducationController)
  // =========================================
  final educationController = TextEditingController();
  final jobStatusController = TextEditingController();
  final incomeController = TextEditingController();
  final RxBool isEducationButtonEnabled = false.obs;

  void validateEducationInputs() {
    isEducationButtonEnabled.value = educationController.text.trim().isNotEmpty &&
                                    jobStatusController.text.trim().isNotEmpty &&
                                    incomeController.text.trim().isNotEmpty;
    updateProfileCompletion();
  }

  Map<String, String> getEducationFormData() {
    return {
      'education': educationController.text.trim(),
      'jobStatus': jobStatusController.text.trim(),
      'income': incomeController.text.trim(),
    };
  }

  // =========================================
  // FAITH & BELIEFS SECTION (from FaithBeliefController)
  // =========================================
  final religions = [
    'Agnostic', 'Atheist', 'Buddhist', 'Christian', 'Hindu',
    'Jewish', 'Muslim', 'Sikh', 'Spiritual', 'Prefer not to say',
  ];
  final selectedReligionIndex = Rxn<int>();

  final zodiacSigns = [
    'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
    'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius',
    'Pisces', 'Not sure', 'Prefer not to say',
  ];
  final selectedZodiacIndex = Rxn<int>();

  void toggleReligion(int index) {
    selectedReligionIndex.value = selectedReligionIndex.value == index ? null : index;
    updateProfileCompletion();
  }

  void toggleZodiac(int index) {
    selectedZodiacIndex.value = selectedZodiacIndex.value == index ? null : index;
    updateProfileCompletion();
  }

  bool get isFaithCompleted =>
      selectedReligionIndex.value != null && selectedZodiacIndex.value != null;

  String? get selectedReligion =>
      selectedReligionIndex.value != null ? religions[selectedReligionIndex.value!] : null;
  String? get selectedZodiac =>
      selectedZodiacIndex.value != null ? zodiacSigns[selectedZodiacIndex.value!] : null;

  // =========================================
  // HABITS SECTION (from HabitController)
  // =========================================
  final communicationStyles = ['Good texter', 'Bad texter', 'Video Chatter', 'Phone caller'];
  final exerciseFrequencies = ['Yes', 'Several times a week', 'Rarely', 'Never'];
  final foodPreferences = ['Healthy and balanced', 'Whatever I feel like', 'Specific diet', "I don't eat"];
  final socialMediaUsage = ['Yes', 'Occasionally', 'Frequently', 'Rarely', 'Never'];
  final smokingDrinking = ['Yes', 'Occasionally', 'No'];
  final tryNewExperiences = ['Absolutely', 'Sometimes', 'Rarely', 'Never'];

  final selectedCommunicationStyle = Rxn<int>();
  final selectedExerciseFrequency = Rxn<int>();
  final selectedFoodPreference = Rxn<int>();
  final selectedSocialMediaUsage = Rxn<int>();
  final selectedSmokingDrinking = Rxn<int>();
  final selectedTryNewExperiences = Rxn<int>();

  void toggleCommunicationStyle(int index) {
    selectedCommunicationStyle.value = selectedCommunicationStyle.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleExerciseFrequency(int index) {
    selectedExerciseFrequency.value = selectedExerciseFrequency.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleFoodPreference(int index) {
    selectedFoodPreference.value = selectedFoodPreference.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleSocialMediaUsage(int index) {
    selectedSocialMediaUsage.value = selectedSocialMediaUsage.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleSmokingDrinking(int index) {
    selectedSmokingDrinking.value = selectedSmokingDrinking.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleTryNewExperiences(int index) {
    selectedTryNewExperiences.value = selectedTryNewExperiences.value == index ? null : index;
    updateProfileCompletion();
  }

  bool get areHabitsCompleted =>
      selectedCommunicationStyle.value != null &&
      selectedExerciseFrequency.value != null &&
      selectedFoodPreference.value != null &&
      selectedSocialMediaUsage.value != null &&
      selectedSmokingDrinking.value != null &&
      selectedTryNewExperiences.value != null;

  // =========================================
  // INSPIRE SECTION (from InspireController)
  // =========================================
  final traits = [
    'Ambition',
    'Emotional intelligence',
    'Curiosity',
    'Humble',
    'Witty',
    'Loyal',
    'Kind',
    'Humour',
  ];

  final RxSet<int> selectedTraitIndices = <int>{}.obs;

  void toggleTrait(int index) {
    if (selectedTraitIndices.contains(index)) {
      selectedTraitIndices.remove(index);
    } else {
      selectedTraitIndices.add(index);
    }
    updateProfileCompletion();
  }

  bool get isInspireButtonEnabled => selectedTraitIndices.length >= 3;

  int get remainingTraitSelections => selectedTraitIndices.length < 3 ? 3 - selectedTraitIndices.length : 0;

  // =========================================
  // INTEREST SECTION (from InterestViewController)
  // =========================================
  final List<Map<String, String>> interestOptions = const [
    {
      'title': 'Long-term partner',
      'description':
          'Building a deep, lasting relationship with shared dreams, trust, and emotional connection'
    },
    {
      'title': 'Casual Connection',
      'description':
          'Keeping things light, fun, and exciting while exploring new people and experiences'
    },
    {
      'title': 'BFF',
      'description':
          'Creating a supportive and joyful bond based on trust, laughter, and shared interests'
    },
  ];

  final RxList<int> selectedInterestIndices = <int>[].obs;

  void toggleInterestSelection(int index) {
    if (selectedInterestIndices.contains(index)) {
      selectedInterestIndices.remove(index);
    } else {
      selectedInterestIndices.add(index);
    }
    updateProfileCompletion();
  }

  String? validateInterestSelections() {
    if (selectedInterestIndices.isEmpty) {
      return 'Please select at least one interest.';
    }
    return null;
  }

  // =========================================
  // LIFESTYLE SECTION (from LifestyleController)
  // =========================================
  final dayPreferences = ['Morning Person', 'Night Owl', 'In Between', 'Depends on the day'];
  final selectedDayPreference = Rxn<int>();

  final loveLanguages = ['Words of Affirmation', 'Quality Time', 'Receiving Gifts', 'Acts of Service', 'Physical Touch'];
  final selectedLoveLanguage = Rxn<int>();

  final weekendActivities = ['Relaxing at home', 'Going out with friends', 'Exploring new places', 'Pursuing hobbies', 'Catching up on work/errands'];
  final selectedWeekendActivity = Rxn<int>();

  final travelPreferences = ['Love traveling', 'Like it occasionally', 'Prefer staying local', 'Depends on the destination'];
  final selectedTravelPreference = Rxn<int>();

  final homeEnvironments = ['Modern', 'Traditional', 'Cozy', 'Rustic', 'Minimalist'];
  final selectedHomeEnvironment = Rxn<int>();

  final livingSpaces = ['Apartment', 'House', 'Townhouse', 'Villa', 'Other'];
  final selectedLivingSpace = Rxn<int>();

  void toggleDayPreference(int index) {
    selectedDayPreference.value = selectedDayPreference.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleLoveLanguage(int index) {
    selectedLoveLanguage.value = selectedLoveLanguage.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleWeekendActivity(int index) {
    selectedWeekendActivity.value = selectedWeekendActivity.value == index ? null : index;
    updateProfileCompletion();
  }
  void toggleTravelPreference(int index) {
    selectedTravelPreference.value = selectedTravelPreference.value == index ? null : index;
    updateProfileCompletion();
  }

  void toggleHomeEnvironment(int index) {
    selectedHomeEnvironment.value = selectedHomeEnvironment.value == index ? null : index;
    updateProfileCompletion();
  }

  void toggleLivingSpace(int index) {
    selectedLivingSpace.value = selectedLivingSpace.value == index ? null : index;
    updateProfileCompletion();
  }

  bool get isLifestyleCompleted =>
      selectedDayPreference.value != null &&
      selectedLoveLanguage.value != null &&
      selectedWeekendActivity.value != null &&
      selectedTravelPreference.value != null &&
      selectedHomeEnvironment.value != null &&
      selectedLivingSpace.value != null;

  // =========================================
  // LIKE TO DO SECTION (from LikeToDoController)
  // =========================================
  final Map<String, List<String>> likeToDoOptions = {
    'creativity': ['Painting','Writing','Photography','Crafting','Design','Drawing','Sculpting','Pottery','Digital Art','Knitting','Calligraphy','Woodworking','Other'],
    'activities': ['Hiking','Cooking','Traveling','Gaming','Reading','Camping','Fishing','Cycling','Photography','Gardening','Other'],
    'sportsFitness': ['Gym','Running','Yoga','Cycling','Swimming','Weight Training','Pilates','Martial Arts','Dance','Hiking','Other'],
    'tvMovies': ['Action','Comedy','Drama','Sci-Fi','Documentary','Thriller','Romance','Horror','Anime','Fantasy','Other'],
    'freeTime': ['Socializing','Meditation','Learning','Volunteering','Shopping','Reading','Gaming','Watching TV/Movies','Listening to Music','Other'],
    'music': ['Pop','Rock','Hip Hop','Classical','Jazz','R&B','Electronic','Country','Reggae','Metal','Other'],
    'wellnessLifestyle': ['Meditation','Healthy Eating','Fitness','Mindfulness','Self-care','Yoga','Veganism','Minimalism','Sustainable Living','Mental Health','Other'],
    'booksContent': ['Fiction','Non-fiction','Biography','Science','History','Fantasy','Mystery','Self-help','Science Fiction','Poetry','Other'],
  };

  final Map<String, RxSet<int>> selectedLikeToDoOptions = {
    'creativity': <int>{}.obs,
    'activities': <int>{}.obs,
    'sportsFitness': <int>{}.obs,
    'tvMovies': <int>{}.obs,
    'freeTime': <int>{}.obs,
    'music': <int>{}.obs,
    'wellnessLifestyle': <int>{}.obs,
    'booksContent': <int>{}.obs,
  };

  void toggleLikeToDoOption(String category, int index) {
    if (selectedLikeToDoOptions[category]!.contains(index)) {
      selectedLikeToDoOptions[category]!.remove(index);
    } else {
      selectedLikeToDoOptions[category]!.add(index);
    }
    updateProfileCompletion();
  }

  bool get isLikeToDoCompleted => selectedLikeToDoOptions.values.every((s) => s.isNotEmpty);

  // =========================================
  // VISUAL STORY SECTION (from VisualStoryController)
  // =========================================
  // Note: Logic is kept in the view as per original design

  // =========================================
  // PROFILE MANAGEMENT
  // =========================================
  void updateProfile() async {
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      // Place API call or local storage update here
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================
  // API SERVICE INTEGRATION
  // =========================================

  /// Initialize the account setup service with authentication token
  void initializeAccountSetupService(String token) {
    _accountSetupService = AccountSetupService(token);
  }

  /// Ensure service is initialized before making API calls
  void _ensureService() {
    try {
      // Accessing a member forces initialization check
      // ignore: unnecessary_statements
      _accountSetupService;
    } catch (_) {
      // Attempt to initialize from LocalStorage
      if (LocalStorage.token.isNotEmpty) {
        initializeAccountSetupService(LocalStorage.token);
      } else {
        Get.snackbar(
          'Authentication Required',
          'Missing bearer token. Please sign in again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        throw Exception('Missing bearer token');
      }
    }
  }

  /// Submit complete profile data without photos
  Future<Map<String, dynamic>> submitCompleteProfile() async {
    _ensureService();

    // Prepare complete profile data
    final profileData = _prepareCompleteProfileData(includeImageFields: true);

    // Use the helper function for API call
    return _handleApiCall(
      'Profile completion',
      () => _accountSetupService.completeProfile(data: profileData),
      successMessage: 'Profile completed successfully!',
      checkVerificationStatus: true,
    );
  }

  // =========================================
  // API METHODS FOR INDIVIDUAL VIEWS
  // =========================================

  /// Submit personal info (intro view)
  Future<Map<String, dynamic>> submitPersonalInfo() async {
    _ensureService();

    final personalInfoData = {
      'first_name': firstName.value,
      'last_name': lastName.value,
      'age': age.value,
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Personal info submission',
      () => _accountSetupService.completeProfile(data: personalInfoData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit gender selection
  Future<Map<String, dynamic>> submitGenderSelection() async {
    _ensureService();

    final genderData = {
      'gender': selectedGender.value,
      'like_to_meet': selectedGenders,
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Gender selection submission',
      () => _accountSetupService.completeProfile(data: genderData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit height and weight
  Future<Map<String, dynamic>> submitHeightWeight() async {
    _ensureService();

    final heightWeightData = {
      'height': heightController.text,
      'weight': weightController.text,
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Height and weight submission',
      () => _accountSetupService.completeProfile(data: heightWeightData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit education information
  Future<Map<String, dynamic>> submitEducation() async {
    _ensureService();

    final educationData = getEducationFormData();

    // Use the helper function for API call
    return _handleApiCall(
      'Education information submission',
      () => _accountSetupService.completeProfile(data: educationData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit faith and belief information
  Future<Map<String, dynamic>> submitFaithBelief() async {
    _ensureService();

    final faithData = {
      'religion': selectedReligion ?? '',
      'zodiac': selectedZodiac ?? '',
      'communication_style': selectedCommunicationStyle.value != null ? communicationStyles[selectedCommunicationStyle.value!] : '',
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Faith and belief information submission',
      () => _accountSetupService.completeProfile(data: faithData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit habits information
  Future<Map<String, dynamic>> submitHabits() async {
    _ensureService();

    final habitsData = {
      'exercise_frequency': selectedExerciseFrequency.value != null ? exerciseFrequencies[selectedExerciseFrequency.value!] : '',
      'food_preference': selectedFoodPreference.value != null ? foodPreferences[selectedFoodPreference.value!] : '',
      'social_media_usage': selectedSocialMediaUsage.value != null ? socialMediaUsage[selectedSocialMediaUsage.value!] : '',
      'smoking_drinking': selectedSmokingDrinking.value != null ? smokingDrinking[selectedSmokingDrinking.value!] : '',
      'try_new_experiences': selectedTryNewExperiences.value != null ? tryNewExperiences[selectedTryNewExperiences.value!] : '',
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Habits information submission',
      () => _accountSetupService.completeProfile(data: habitsData),
      showSuccessSnackbar: false,
    );
  }

  /// Submit personality traits
  Future<Map<String, dynamic>> submitTraits() async {
    _ensureService();

    final traitsData = {
      'personality_traits': selectedTraitIndices.map((index) => traits[index]).toList(),
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Personality traits submission',
      () => _accountSetupService.completeProfile(data: traitsData),
      showSuccessSnackbar: false,
    );
  }
// MARK : wqerfpweiourpweiourgp9weui
  /// Submit interests
  Future<Map<String, dynamic>> submitInterests() async {
    _ensureService();

    final interestsData = {
      'interests': selectedInterestIndices.map((index) => interestOptions[index]['title']).toList(),
    };

    // Use the helper function for API call
    return _handleApiCall(
      'Interests submission',
      () => _accountSetupService.completeProfile(data: interestsData),
      showSuccessSnackbar: false,
    );
  }

  bool validateAllSections() {
    if (firstName.value.isEmpty || lastName.value.isEmpty || age.value.isEmpty) {
      Get.snackbar('Validation Error', 'Please complete personal information',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!isGenderSelected) {
      Get.snackbar('Validation Error', 'Please select your gender',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (selectedGenders.isEmpty) {
      Get.snackbar('Validation Error', 'Please select who you like to meet',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!areHeightWeightValid) {
      Get.snackbar('Validation Error', 'Please enter height and weight',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!isEducationButtonEnabled.value) {
      Get.snackbar('Validation Error', 'Please complete education information',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!isFaithCompleted) {
      Get.snackbar('Validation Error', 'Please select religion and zodiac',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (!areHabitsCompleted) {
      Get.snackbar('Validation Error', 'Please complete all habit selections',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }


    if (!isInspireButtonEnabled) {
      Get.snackbar('Validation Error', 'Please select at least 3 personality traits',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (selectedInterestIndices.isEmpty) {
      Get.snackbar('Validation Error', 'Please select at least one interest',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }


    if (!isLifestyleCompleted) {
      Get.snackbar('Validation Error', 'Please complete lifestyle preferences',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }


    if (!isLikeToDoCompleted) {
      Get.snackbar('Validation Error', 'Please select at least one option from each category',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  @override
  void onInit() {
    super.onInit();

    loadUserData();
  }

  @override
  void onClose() {

    firstNameController.dispose();
    lastNameController.dispose();
    ageController.dispose();
    heightController.dispose();
    weightController.dispose();
    educationController.dispose();
    jobStatusController.dispose();
    incomeController.dispose();
    super.onClose();
  }


  Future<Map<String, dynamic>> uploadThreeSpecificImages({
    required String bodyImagePath,
    required String headShotImagePath,
    required String personalityImagePath,
  }) async {
    _ensureService();

    // Convert to File objects
    final bodyImage = bodyImagePath.isNotEmpty ? File(bodyImagePath) : null;
    final headShotImage = headShotImagePath.isNotEmpty ? File(headShotImagePath) : null;
    final personalityImage = personalityImagePath.isNotEmpty ? File(personalityImagePath) : null;


    _logImagePreparation('PREPARING IMAGES FOR UPLOAD', {
      'bodyImage': bodyImage?.path,
      'headShotImage': headShotImage?.path,
      'personalityImage': personalityImage?.path,
    });


    if (bodyImage == null || headShotImage == null || personalityImage == null) {
        return {
        'success': false,
        'message': 'All 3 images (body, headshot, personality) are required',
      };
    }

    final imageFiles = {
      'bodyImage': bodyImage,
      'headShotImage': headShotImage,
      'personalityImage': personalityImage,
    };
    
    if (!await _validateImageFiles(imageFiles)) {
      return {
        'success': false,
        'message': 'One or more image files are missing or invalid',
      };
    }


    return _handleApiCall(
      '3 specific images upload',
      () => _accountSetupService.uploadSpecificImages(
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
      ),
      successMessage: 'Images uploaded successfully!',
    );
  }

  void clearAllData() {
    firstName.value = '';
    lastName.value = '';
    age.value = '';
    selectedGender.value = '';
    selectedGenders.clear();
    heightController.clear();
    weightController.clear();
    educationController.clear();
    jobStatusController.clear();
    incomeController.clear();
    selectedReligionIndex.value = null;
    selectedZodiacIndex.value = null;
    selectedCommunicationStyle.value = null;
    selectedExerciseFrequency.value = null;
    selectedFoodPreference.value = null;
    selectedSocialMediaUsage.value = null;
    selectedSmokingDrinking.value = null;
    selectedTryNewExperiences.value = null;
    selectedTraitIndices.clear();
    selectedInterestIndices.clear();
    selectedDayPreference.value = null;
    selectedLoveLanguage.value = null;
    selectedWeekendActivity.value = null;
    selectedTravelPreference.value = null;
    selectedLikeToDoOptions.forEach((category, indices) {
      indices.clear();
    });
  }

  void updateProfileCompletion() {
    int completedSections = 0;
    int totalSections = 12; 


    if (firstName.value.isNotEmpty && lastName.value.isNotEmpty && age.value.isNotEmpty) completedSections++;
    if (isGenderSelected) completedSections++;
    if (selectedGenders.isNotEmpty) completedSections++;
    if (areHeightWeightValid) completedSections++;
    if (isEducationButtonEnabled.value) completedSections++;
    if (isFaithCompleted) completedSections++;
    if (areHabitsCompleted) completedSections++;
    if (isInspireButtonEnabled) completedSections++;
    if (selectedInterestIndices.isNotEmpty) completedSections++;
    if (isLifestyleCompleted) completedSections++;
    if (isLikeToDoCompleted) completedSections++;

    profileCompletionPercentage.value = (completedSections / totalSections * 100).round();
  }
  
  int getCompletionPercentage() {
    return profileCompletionPercentage.value;
  }
}