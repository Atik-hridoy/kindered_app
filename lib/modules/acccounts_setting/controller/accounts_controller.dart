import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../services/account_setup_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../model/complete_profile.dart';

class AccountsController extends GetxController {
  // Service instance
  late AccountSetupService _accountSetupService;

  // Loading state
  final RxBool isLoading = false.obs;

  // Profile completion percentage
  final RxInt profileCompletionPercentage = 0.obs;

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
      'homeEnvironment': '', // Not collected in current flow
      'livingSpace': '', // Not collected in current flow
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
  Map<String, dynamic> _prepareCompleteProfileData() {
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
      // three named images will be sent via multipart; here we keep placeholders if server also parses JSON
      'bodyImage': '',
      'headShotImage': '',
      'personalityImage': '',
      // extra images array required by server schema
      'image': <String>[],
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
      'isVerified': false, // Default verification status
      'profileCompletionPercentage': getCompletionPercentage(),
      'isDeleted': false, // Default deletion status
    };

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
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting complete profile WITH photos: count=${photoPaths.length}');

      final profileData = _prepareCompleteProfileData();

      // Convert to File list for the service
      final files = photoPaths.where((p) => p.isNotEmpty).map((p) => File(p)).toList();
      AppLogger.info('🖼️ PHOTO PROCESSING:');
      AppLogger.info('  • Valid Photo Paths: ${files.length}');
      for (int i = 0; i <files.length; i++) {
        AppLogger.info('  • Photo ${i + 1}: ${files[i].path}');
      }

      // Map first three images to named fields per backend: bodyImage, headShotImage, personalityImage
      File? bodyImage;
      File? headShotImage;
      File? personalityImage;
      final extraImages = <File>[];
      if (files.isNotEmpty) bodyImage = files[0];
      if (files.length > 1) headShotImage = files[1];
      if (files.length > 2) personalityImage = files[2];
      if (files.length > 3) extraImages.addAll(files.sublist(3));

      AppLogger.info('📤 IMAGE MAPPING:');
      AppLogger.info('  • Body Image: ${bodyImage?.path ?? 'Not provided'}');
      AppLogger.info('  • Head Shot Image: ${headShotImage?.path ?? 'Not provided'}');
      AppLogger.info('  • Personality Image: ${personalityImage?.path ?? 'Not provided'}');
      AppLogger.info('  • Extra Images Count: ${extraImages.length}');

      AppLogger.info('🌐 SENDING TO BACKEND...');
      final response = await _accountSetupService.completeProfileMultipart(
        data: profileData,
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
        extraImages: extraImages,
      );

      AppLogger.info('📡 BACKEND RESPONSE:');
      AppLogger.info('  • Status Code: ${response.statusCode}');
      AppLogger.info('  • Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        AppLogger.info('✅ SUCCESSFUL SUBMISSION:');
        AppLogger.info('  • Success: ${result['success']}');
        AppLogger.info('  • Message: ${result['message'] ?? 'No message'}');
        AppLogger.info('  • Full Response: $result');

        if (result['success'] == true) {
          AppLogger.success('🎉 Profile submitted successfully with photos!');
          Get.snackbar('Success', 'Profile submitted successfully!',
              snackPosition: SnackPosition.BOTTOM);
          // Navigate to location view after successful submission
          Get.offAllNamed(AppRoutes.locationView);
        } else {
          AppLogger.warning('⚠️ Profile submit response not successful: ${result['message']}');
          Get.snackbar('Error', result['message'] ?? 'Profile submission failed',
              snackPosition: SnackPosition.BOTTOM);
        }
        return result;
      } else {
        AppLogger.error('❌ PROFILE SUBMISSION FAILED:');
        AppLogger.error('  • Status Code: ${response.statusCode}');
        AppLogger.error('  • Response Data: ${response.data}');
        AppLogger.error('  • Status Message: ${response.statusMessage}');
        Get.snackbar('Error', 'Profile submission failed. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
        return {'success': false, 'message': 'Profile submission failed'};
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ EXCEPTION DURING PROFILE SUBMISSION:');
      AppLogger.error('  • Error: $e');
      AppLogger.error('  • Stack Trace: $stackTrace');
      AppLogger.error('  • Error Type: ${e.runtimeType}');
      Get.snackbar('Error', 'An error occurred. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return {'success': false, 'message': 'An error occurred'};
    } finally {
      isLoading.value = false;
      AppLogger.info('🔄 Loading state reset to false');
    }
  }

  /// Submit complete profile data using CompleteProfile model
  Future<Map<String, dynamic>> submitCompleteProfileUsingModel() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting complete profile data using CompleteProfile model');

      // Create CompleteProfile instance using current controller data
      final completeProfile = _createCompleteProfileInstance();
      
      // Use the model's toJson() method to get properly structured data
      final profileData = completeProfile.toJson();
      
      AppLogger.info('📋 PROFILE DATA PREPARED:');
      AppLogger.info('  • First Name: ${completeProfile.firstName}');
      AppLogger.info('  • Last Name: ${completeProfile.lastName}');
      AppLogger.info('  • Age: ${completeProfile.age}');
      AppLogger.info('  • Gender: ${completeProfile.gender}');
      AppLogger.info('  • Email: ${completeProfile.email}');
      AppLogger.info('  • Profile Completion: ${completeProfile.profileCompletionPercentage}%');

      AppLogger.info('🌐 SENDING TO BACKEND...');
      final response = await _accountSetupService.completeProfile(
        data: profileData,
      );
      AppLogger.info('📡 BACKEND RESPONSE:');
      AppLogger.info('  • Status Code: ${response.statusCode}');
      AppLogger.info('  • Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        AppLogger.info('✅ SUCCESSFUL SUBMISSION:');
        AppLogger.info('  • Success: ${result['success']}');
        AppLogger.info('  • Message: ${result['message'] ?? 'No message'}');
        AppLogger.info('  • Full Response: $result');

        if (result['success'] == true) {
          AppLogger.success('🎉 Profile submitted successfully using CompleteProfile model!');
          Get.snackbar('Success', 'Profile submitted successfully!',
              snackPosition: SnackPosition.BOTTOM);
          // Navigate to location view after successful submission
          Get.offAllNamed(AppRoutes.locationView);
        } else {
          AppLogger.warning('⚠️ Profile submit response not successful: ${result['message']}');
          Get.snackbar('Error', result['message'] ?? 'Profile submission failed',
              snackPosition: SnackPosition.BOTTOM);
        }
        return result;
      } else {
        AppLogger.error('❌ PROFILE SUBMISSION FAILED:');
        AppLogger.error('  • Status Code: ${response.statusCode}');
        AppLogger.error('  • Response Data: ${response.data}');
        AppLogger.error('  • Status Message: ${response.statusMessage}');
        Get.snackbar('Error', 'Profile submission failed. Please try again.',
            snackPosition: SnackPosition.BOTTOM);
        return {'success': false, 'message': 'Profile submission failed'};
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ EXCEPTION DURING PROFILE SUBMISSION:');
      AppLogger.error('  • Error: $e');
      AppLogger.error('  • Stack Trace: $stackTrace');
      AppLogger.error('  • Error Type: ${e.runtimeType}');
      Get.snackbar('Error', 'An error occurred. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
      return {'success': false, 'message': 'An error occurred'};
    } finally {
      isLoading.value = false;
      AppLogger.info('🔄 Loading state reset to false');
    }
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
      isVerified: false,
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

  bool get isLifestyleCompleted =>
      selectedDayPreference.value != null &&
      selectedLoveLanguage.value != null &&
      selectedWeekendActivity.value != null &&
      selectedTravelPreference.value != null;

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
    AppLogger.info('🔗 Setting up AccountSetupService with bearer token (len=${token.length})');
    _accountSetupService = AccountSetupService(token);
  }

  /// Ensure service is initialized before making API calls
  void _ensureService() {
    try {
      // Accessing a member forces initialization check
      // ignore: unnecessary_statements
      _accountSetupService;
      AppLogger.debug('✅ AccountSetupService already initialized');
    } catch (_) {
      // Attempt to initialize from LocalStorage
      if (LocalStorage.token.isNotEmpty) {
        AppLogger.info('♻️ Re-initializing AccountSetupService from stored token');
        initializeAccountSetupService(LocalStorage.token);
      } else {
        AppLogger.warning('❌ Missing bearer token. Cannot call AccountSetupService');
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
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting complete profile (without photos)');

      // Prepare complete profile data
      final profileData = _prepareCompleteProfileData();
      AppLogger.debug('🧾 Payload keys: ${profileData.keys.toList()}');

      final response = await _accountSetupService.completeProfile(data: profileData);

      // Check if the response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;

        if (result['success'] == true) {
          AppLogger.success('✅ Profile completed successfully');
          Get.snackbar('Success', 'Profile completed successfully!',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          AppLogger.warning('⚠️ Profile completion response not successful: ${result['message']}');
          Get.snackbar('Error', result['message'] ?? 'Profile completion failed',
              snackPosition: SnackPosition.BOTTOM);
        }

        return result;
      } else {
        final errorMessage = 'Failed to complete profile: ${response.statusCode}';
        AppLogger.error(errorMessage);
        Get.snackbar('Error', errorMessage,
            snackPosition: SnackPosition.BOTTOM);
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitCompleteProfile: $e');
      Get.snackbar('Error', 'Failed to complete profile: $e',
          snackPosition: SnackPosition.BOTTOM);
      return {
        'success': false,
        'message': 'Failed to complete profile: $e',
      };
    } finally {
      isLoading.value = false;
      AppLogger.info('🛑 submitCompleteProfile finished');
    }
  }

  // =========================================
  // API METHODS FOR INDIVIDUAL VIEWS
  // =========================================

  /// Submit personal info (intro view)
  Future<Map<String, dynamic>> submitPersonalInfo() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting personal info');

      final personalInfoData = {
        'first_name': firstName.value,
        'last_name': lastName.value,
        'age': age.value,
      };

      final response = await _accountSetupService.completeProfile(data: personalInfoData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Personal info submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit personal info: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitPersonalInfo: $e');
      return {'success': false, 'message': 'Failed to submit personal info: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit gender selection
  Future<Map<String, dynamic>> submitGenderSelection() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting gender selection');

      final genderData = {
        'gender': selectedGender.value,
        'like_to_meet': selectedGenders,
      };

      final response = await _accountSetupService.completeProfile(data: genderData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Gender selection submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit gender selection: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitGenderSelection: $e');
      return {'success': false, 'message': 'Failed to submit gender selection: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit height and weight
  Future<Map<String, dynamic>> submitHeightWeight() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting height and weight');

      final heightWeightData = {
        'height': heightController.text,
        'weight': weightController.text,
      };

      final response = await _accountSetupService.completeProfile(data: heightWeightData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Height and weight submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit height and weight: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitHeightWeight: $e');
      return {'success': false, 'message': 'Failed to submit height and weight: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit education information
  Future<Map<String, dynamic>> submitEducation() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting education information');

      final educationData = getEducationFormData();

      final response = await _accountSetupService.completeProfile(data: educationData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Education information submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit education information: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitEducation: $e');
      return {'success': false, 'message': 'Failed to submit education information: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit faith and belief information
  Future<Map<String, dynamic>> submitFaithBelief() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting faith and belief information');

      final faithData = {
        'religion': selectedReligion ?? '',
        'zodiac': selectedZodiac ?? '',
        'communication_style': selectedCommunicationStyle.value != null ? communicationStyles[selectedCommunicationStyle.value!] : '',
      };

      final response = await _accountSetupService.completeProfile(data: faithData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Faith and belief information submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit faith and belief information: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitFaithBelief: $e');
      return {'success': false, 'message': 'Failed to submit faith and belief information: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit habits information
  Future<Map<String, dynamic>> submitHabits() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting habits information');

      final habitsData = {
        'exercise_frequency': selectedExerciseFrequency.value != null ? exerciseFrequencies[selectedExerciseFrequency.value!] : '',
        'food_preference': selectedFoodPreference.value != null ? foodPreferences[selectedFoodPreference.value!] : '',
        'social_media_usage': selectedSocialMediaUsage.value != null ? socialMediaUsage[selectedSocialMediaUsage.value!] : '',
        'smoking_drinking': selectedSmokingDrinking.value != null ? smokingDrinking[selectedSmokingDrinking.value!] : '',
        'try_new_experiences': selectedTryNewExperiences.value != null ? tryNewExperiences[selectedTryNewExperiences.value!] : '',
      };

      final response = await _accountSetupService.completeProfile(data: habitsData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Habits information submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit habits information: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitHabits: $e');
      return {'success': false, 'message': 'Failed to submit habits information: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit personality traits
  Future<Map<String, dynamic>> submitTraits() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting personality traits');

      final traitsData = {
        'personality_traits': selectedTraitIndices.map((index) => traits[index]).toList(),
      };

      final response = await _accountSetupService.completeProfile(data: traitsData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Personality traits submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit personality traits: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitTraits: $e');
      return {'success': false, 'message': 'Failed to submit personality traits: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit interests
  Future<Map<String, dynamic>> submitInterests() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting interests');

      final interestsData = {
        'interests': selectedInterestIndices.map((index) => interestOptions[index]['title']).toList(),
      };

      final response = await _accountSetupService.completeProfile(data: interestsData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Interests submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit interests: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitInterests: $e');
      return {'success': false, 'message': 'Failed to submit interests: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit lifestyle preferences
  Future<Map<String, dynamic>> submitLifestyle() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting lifestyle preferences');

      final lifestyleData = {
        'day_preference': selectedDayPreference.value != null ? dayPreferences[selectedDayPreference.value!] : '',
        'love_language': selectedLoveLanguage.value != null ? loveLanguages[selectedLoveLanguage.value!] : '',
        'weekend_activity': selectedWeekendActivity.value != null ? weekendActivities[selectedWeekendActivity.value!] : '',
        'travel_preference': selectedTravelPreference.value != null ? travelPreferences[selectedTravelPreference.value!] : '',
      };

      final response = await _accountSetupService.completeProfile(data: lifestyleData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ Lifestyle preferences submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit lifestyle preferences: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitLifestyle: $e');
      return {'success': false, 'message': 'Failed to submit lifestyle preferences: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  /// Submit "like to do" preferences
  Future<Map<String, dynamic>> submitLikeToDo() async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting "like to do" preferences');

      final likeToDoData = <String, List<String>>{};

      selectedLikeToDoOptions.forEach((category, indices) {
        if (indices.isNotEmpty) {
          likeToDoData[category] = indices.map((index) => likeToDoOptions[category]![index]).toList();
        }
      });

      final response = await _accountSetupService.completeProfile(data: likeToDoData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLogger.success('✅ "Like to do" preferences submitted successfully');
        return response.data as Map<String, dynamic>;
      } else {
        final errorMessage = 'Failed to submit "like to do" preferences: ${response.statusCode}';
        AppLogger.error(errorMessage);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitLikeToDo: $e');
      return {'success': false, 'message': 'Failed to submit "like to do" preferences: $e'};
    } finally {
      isLoading.value = false;
    }
  }

  // =========================================
  // VALIDATION METHODS
  // =========================================
  bool validateAllSections() {
    // Personal info validation
    if (firstName.value.isEmpty || lastName.value.isEmpty || age.value.isEmpty) {
      Get.snackbar('Validation Error', 'Please complete personal information',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Gender validation
    if (!isGenderSelected) {
      Get.snackbar('Validation Error', 'Please select your gender',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Choice validation
    if (selectedGenders.isEmpty) {
      Get.snackbar('Validation Error', 'Please select who you like to meet',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Height & weight validation
    if (!areHeightWeightValid) {
      Get.snackbar('Validation Error', 'Please enter height and weight',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Education validation
    if (!isEducationButtonEnabled.value) {
      Get.snackbar('Validation Error', 'Please complete education information',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Faith validation
    if (!isFaithCompleted) {
      Get.snackbar('Validation Error', 'Please select religion and zodiac',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Habits validation
    if (!areHabitsCompleted) {
      Get.snackbar('Validation Error', 'Please complete all habit selections',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Inspire validation
    if (!isInspireButtonEnabled) {
      Get.snackbar('Validation Error', 'Please select at least 3 personality traits',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Interest validation
    if (selectedInterestIndices.isEmpty) {
      Get.snackbar('Validation Error', 'Please select at least one interest',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Lifestyle validation
    if (!isLifestyleCompleted) {
      Get.snackbar('Validation Error', 'Please complete lifestyle preferences',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    // Like to do validation
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
    // Initialize controllers and set up listeners
    loadUserData();
  }

  @override
  void onClose() {
    // Dispose of controllers
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

  /// Upload the 3 specific images separately: bodyImage, headShotImage, and personalityImage
  /// This method handles only the image upload part, separate from profile data submission
  Future<Map<String, dynamic>> uploadThreeSpecificImages({
    required String bodyImagePath,
    required String headShotImagePath,
    required String personalityImagePath,
  }) async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Uploading 3 specific images separately');

      // Convert to File objects
      final bodyImage = bodyImagePath.isNotEmpty ? File(bodyImagePath) : null;
      final headShotImage = headShotImagePath.isNotEmpty ? File(headShotImagePath) : null;
      final personalityImage = personalityImagePath.isNotEmpty ? File(personalityImagePath) : null;

      AppLogger.info('🖼️ PREPARING IMAGES FOR UPLOAD:');
      AppLogger.info('  • Body Image: ${bodyImage?.path ?? 'Not provided'}');
      AppLogger.info('  • Head Shot Image: ${headShotImage?.path ?? 'Not provided'}');
      AppLogger.info('  • Personality Image: ${personalityImage?.path ?? 'Not provided'}');

      // Validate that all 3 images are provided
      if (bodyImage == null || headShotImage == null || personalityImage == null) {
        AppLogger.warning('⚠️ Missing required images for upload');
        return {
          'success': false,
          'message': 'All 3 images (body, headshot, personality) are required',
        };
      }

      // Validate that files exist
      if (!await bodyImage.exists() || !await headShotImage.exists() || !await personalityImage.exists()) {
        AppLogger.warning('⚠️ One or more image files do not exist');
        return {
          'success': false,
          'message': 'One or more image files are missing or invalid',
        };
      }

      AppLogger.info('🌐 SENDING IMAGES TO BACKEND...');
      final response = await _accountSetupService.uploadSpecificImages(
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
      );

      AppLogger.info('📡 BACKEND RESPONSE:');
      AppLogger.info('  • Status Code: ${response.statusCode}');
      AppLogger.info('  • Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        AppLogger.info('✅ SUCCESSFUL IMAGE UPLOAD:');
        AppLogger.info('  • Success: ${result['success']}');
        AppLogger.info('  • Message: ${result['message'] ?? 'No message'}');
        AppLogger.info('  • Full Response: $result');

        if (result['success'] == true) {
          AppLogger.success('🎉 3 specific images uploaded successfully!');
          Get.snackbar(
            'Success',
            'Images uploaded successfully!',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          AppLogger.warning('⚠️ Image upload response not successful: ${result['message']}');
          Get.snackbar(
            'Error',
            result['message'] ?? 'Image upload failed',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        return result;
      } else {
        AppLogger.error('❌ IMAGE UPLOAD FAILED:');
        AppLogger.error('  • Status Code: ${response.statusCode}');
        AppLogger.error('  • Response Data: ${response.data}');
        AppLogger.error('  • Status Message: ${response.statusMessage}');
        Get.snackbar(
          'Error',
          'Image upload failed. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return {'success': false, 'message': 'Image upload failed'};
      }
    } catch (e, stackTrace) {
      AppLogger.error('❌ EXCEPTION DURING IMAGE UPLOAD:');
      AppLogger.error('  • Error: $e');
      AppLogger.error('  • Stack Trace: $stackTrace');
      AppLogger.error('  • Error Type: ${e.runtimeType}');
      Get.snackbar(
        'Error',
        'An error occurred during image upload. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return {'success': false, 'message': 'An error occurred during image upload'};
    } finally {
      isLoading.value = false;
      AppLogger.info('🔄 Loading state reset to false');
    }
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
    int totalSections = 12; // Total number of sections to complete

    // Check each section for completion
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