import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../services/account_setup_service.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

class AccountsController extends GetxController {
  // Service instance
  late AccountSetupService _accountSetupService;
  
  // Loading state
  final RxBool isLoading = false.obs;
  
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
  
  void updateFirstName(String value) => firstName.value = value;
  void updateLastName(String value) => lastName.value = value;
  void updateAge(String value) => age.value = value;
  
  void loadUserData() {
    firstName.value = '';
    lastName.value = '';
    age.value = '';
    // Keep text controllers in sync
    firstNameController.text = firstName.value;
    lastNameController.text = lastName.value;
    ageController.text = age.value;
  }

  /// Build payload that matches backend keys based on Postman screenshot
  Map<String, dynamic> _prepareBackendCompleteProfileData() {
    // Helpers to extract safe values
    String _str(String? v) => (v ?? '').trim();
    int _int(String? v) => int.tryParse((v ?? '').trim()) ?? 0;

    // Like-to-meet / relation type may come from choice view; best-effort mapping
    // For now, attempt to reuse existing selected values if present; otherwise send empty types

    final Map<String, dynamic> body = {
      // Map from physical_attributes if needed; placeholder empty structure
      'height': _str(heightController.text),
      'weight': _str(weightController.text),
    };

    final Map<String, dynamic> eduJob = getEducationFormData();

    final Map<String, dynamic> lifestyle = {
      'sleepingStyle': selectedDayPreference.value != null ? dayPreferences[selectedDayPreference.value!] : '',
      'loveStyle': selectedLoveLanguage.value != null ? loveLanguages[selectedLoveLanguage.value!] : '',
      'weekends': selectedWeekendActivity.value != null ? weekendActivities[selectedWeekendActivity.value!] : '',
      'traveling': selectedTravelPreference.value != null ? travelPreferences[selectedTravelPreference.value!] : '',
      'homeEnvironment': '',
      'livingSpace': '',
    };

    final Map<String, dynamic> habitsPayload = {
      'communicationStyle': selectedCommunicationStyle.value != null ? [communicationStyles[selectedCommunicationStyle.value!]] : <String>[],
      'workout': selectedExerciseFrequency.value != null ? exerciseFrequencies[selectedExerciseFrequency.value!] : '',
      'eatingStyle': selectedFoodPreference.value != null ? [foodPreferences[selectedFoodPreference.value!]] : <String>[],
      'socialMedia': selectedSocialMediaUsage.value != null ? socialMediaUsage[selectedSocialMediaUsage.value!] : '',
      'smokeOrDrink': selectedSmokingDrinking.value != null ? smokingDrinking[selectedSmokingDrinking.value!] : '',
      'newExercise': selectedTryNewExperiences.value != null ? tryNewExperiences[selectedTryNewExperiences.value!] : '',
    };

    // Interests: flatten into arrays; if none selected, send []
    final Map<String, List<String>> interestsPayload = {
      'hobbies': <String>[],
      'creativeOutlets': <String>[],
      'fitnessAndSports': <String>[],
      'entertainment': <String>[],
      'leisureActivities': <String>[],
      'musicGenres': <String>[],
      'healthAndWellness': <String>[],
      'readingAndContent': <String>[],
    };
    // If you have categories in interestOptions, you can populate accordingly; otherwise keep empty arrays.

    // Traits/inspire
    final List<String> personalTraitsInspire = selectedTraitIndices.map((i) => traits[i]).toList();

    final Map<String, dynamic> payload = {
      'email': _str(LocalStorage.myEmail),
      'firstName': _str(firstName.value),
      'lastName': _str(lastName.value),
      'phone': _str(LocalStorage.phone),
      'age': _int(age.value),
      'gender': _str(selectedGender.value),
      'relationType': '',
      'religion': _str(selectedReligion),
      'zodiacSign': _str(selectedZodiac),
      // three named images will be sent via multipart; here we keep placeholders if server also parses JSON
      'bodyImage': '',
      'headShotImage': '',
      'personalityImage': '',
      // extra images array required by server schema
      'image': <String>[],
      'likeToMeet': <String>[],
      'personalTraitsInspire': personalTraitsInspire,
      'body': body,
      'eduJob': eduJob,
      'lifestyle': lifestyle,
      'habits': habitsPayload,
      'interests': interestsPayload,
      'beliefsOtherText': '',
      'address': _str(LocalStorage.myAddress),
      'traitsOtherText': '',
      'aboutMe': '',
    };

    AppLogger.debug('🧾 Backend payload keys: ${payload.keys.toList()}');
    return payload;
  }

  /// Submit complete profile with optional photos
  Future<Map<String, dynamic>> submitCompleteProfileWithPhotos(List<String> photoPaths) async {
    try {
      isLoading.value = true;
      _ensureService();
      AppLogger.info('🚀 Submitting complete profile WITH photos: count=${photoPaths.length}');

      final profileData = _prepareBackendCompleteProfileData();

      // Convert to File list for the service
      final files = photoPaths.where((p) => p.isNotEmpty).map((p) => File(p)).toList();
      AppLogger.debug('🖼️ Resolved photo files: ${files.length}');

      // Map first three images to named fields per backend: bodyImage, headShotImage, personalityImage
      File? bodyImage;
      File? headShotImage;
      File? personalityImage;
      final extraImages = <File>[];
      if (files.isNotEmpty) bodyImage = files[0];
      if (files.length > 1) headShotImage = files[1];
      if (files.length > 2) personalityImage = files[2];
      if (files.length > 3) extraImages.addAll(files.sublist(3));

      final response = await _accountSetupService.completeProfileMultipart(
        data: profileData,
        bodyImage: bodyImage,
        headShotImage: headShotImage,
        personalityImage: personalityImage,
        extraImages: extraImages,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data as Map<String, dynamic>;
        if (result['success'] == true) {
          AppLogger.success('✅ Profile submitted successfully with photos');
          Get.snackbar('Success', 'Profile submitted successfully!',
              snackPosition: SnackPosition.BOTTOM);
        } else {
          AppLogger.warning('⚠️ Profile submit response not successful: ${result['message']}');
          Get.snackbar('Error', result['message'] ?? 'Profile submission failed',
              snackPosition: SnackPosition.BOTTOM);
        }
        return result;
      } else {
        final errorMessage = 'Failed to submit profile: ${response.statusCode}';
        AppLogger.error(errorMessage);
        Get.snackbar('Error', errorMessage, snackPosition: SnackPosition.BOTTOM);
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      AppLogger.error('❌ Exception during submitCompleteProfileWithPhotos: $e');
      Get.snackbar('Error', 'Failed to submit profile: $e',
          snackPosition: SnackPosition.BOTTOM);
      return {
        'success': false,
        'message': 'Failed to submit profile: $e',
      };
    } finally {
      isLoading.value = false;
      AppLogger.info('🛑 submitCompleteProfileWithPhotos finished');
    }
  }
  
  void onNextPressed() {
    if (firstName.value.isEmpty || lastName.value.isEmpty || age.value.isEmpty) {
      AppLogger.warning('⚠️ Personal info incomplete: firstName=${firstName.value.isNotEmpty}, lastName=${lastName.value.isNotEmpty}, age=${age.value.isNotEmpty}');
      Get.snackbar('Validation Error', 'Please complete the form before proceeding.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    AppLogger.info('➡️ Personal info valid. Proceeding to Gender view');
    updateProfile();
    Get.offAllNamed(AppRoutes.gender);
  }
  
  // =========================================
  // GENDER SELECTION SECTION (from GenderViewController)
  // =========================================
  final RxString selectedGender = ''.obs;
  
  bool get isGenderSelected => selectedGender.value.isNotEmpty;
  
  void selectGender(String gender) {
    selectedGender.value = gender;
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
  }
  
  void toggleZodiac(int index) {
    selectedZodiacIndex.value = selectedZodiacIndex.value == index ? null : index;
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
  
  void toggleCommunicationStyle(int index) => selectedCommunicationStyle.value = selectedCommunicationStyle.value == index ? null : index;
  void toggleExerciseFrequency(int index) => selectedExerciseFrequency.value = selectedExerciseFrequency.value == index ? null : index;
  void toggleFoodPreference(int index) => selectedFoodPreference.value = selectedFoodPreference.value == index ? null : index;
  void toggleSocialMediaUsage(int index) => selectedSocialMediaUsage.value = selectedSocialMediaUsage.value == index ? null : index;
  void toggleSmokingDrinking(int index) => selectedSmokingDrinking.value = selectedSmokingDrinking.value == index ? null : index;
  void toggleTryNewExperiences(int index) => selectedTryNewExperiences.value = selectedTryNewExperiences.value == index ? null : index;
  
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
  
  void toggleDayPreference(int index) => selectedDayPreference.value = selectedDayPreference.value == index ? null : index;
  void toggleLoveLanguage(int index) => selectedLoveLanguage.value = selectedLoveLanguage.value == index ? null : index;
  void toggleWeekendActivity(int index) => selectedWeekendActivity.value = selectedWeekendActivity.value == index ? null : index;
  void toggleTravelPreference(int index) => selectedTravelPreference.value = selectedTravelPreference.value == index ? null : index;
  
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
  // ACCOUNT SETUP SERVICE INTEGRATION
  // =========================================
  void initializeAccountSetupService(String token) {
    AppLogger.info('🔗 Setting up AccountSetupService with bearer token (len=${token.length})');
    _accountSetupService = AccountSetupService(token);
  }

  // Ensure service is initialized with a bearer token before any API call
  void _ensureService() {
    try {
      // If _accountSetupService was never set, this will throw
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
  
  Future<Map<String, dynamic>> completeProfile() async {
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
      AppLogger.error('❌ Exception during completeProfile: $e');
      Get.snackbar('Error', 'Failed to complete profile: $e',
          snackPosition: SnackPosition.BOTTOM);
      return {
        'success': false,
        'message': 'Failed to complete profile: $e',
      };
    } finally {
      isLoading.value = false;
      AppLogger.info('🛑 completeProfile finished');
    }
  }
  
  Map<String, dynamic> _prepareCompleteProfileData() {
    final payload = {
      'email': LocalStorage.myEmail,
      'personal_info': {
        'first_name': firstName.value,
        'last_name': lastName.value,
        'age': age.value,
        'gender': selectedGender.value,
      },
      'physical_attributes': {
        'height': heightController.text,
        'weight': weightController.text,
      },
      'education_career': getEducationFormData(),
      'faith_beliefs': {
        'religion': selectedReligion,
        'zodiac': selectedZodiac,
      },
      'habits': {
        'communication_style': selectedCommunicationStyle.value != null ? communicationStyles[selectedCommunicationStyle.value!] : null,
        'exercise_frequency': selectedExerciseFrequency.value != null ? exerciseFrequencies[selectedExerciseFrequency.value!] : null,
        'food_preference': selectedFoodPreference.value != null ? foodPreferences[selectedFoodPreference.value!] : null,
        'social_media_usage': selectedSocialMediaUsage.value != null ? socialMediaUsage[selectedSocialMediaUsage.value!] : null,
        'smoking_drinking': selectedSmokingDrinking.value != null ? smokingDrinking[selectedSmokingDrinking.value!] : null,
        'try_new_experiences': selectedTryNewExperiences.value != null ? tryNewExperiences[selectedTryNewExperiences.value!] : null,
      },
      'inspire': {
        'selected_traits': selectedTraitIndices.map((index) => traits[index]).toList(),
      },
      'interests': {
        'selected_interests': selectedInterestIndices.map((index) => interestOptions[index]['title']).toList(),
      },
      'lifestyle': {
        'day_preference': selectedDayPreference.value != null ? dayPreferences[selectedDayPreference.value!] : null,
        'love_language': selectedLoveLanguage.value != null ? loveLanguages[selectedLoveLanguage.value!] : null,
        'weekend_activity': selectedWeekendActivity.value != null ? weekendActivities[selectedWeekendActivity.value!] : null,
        'travel_preference': selectedTravelPreference.value != null ? travelPreferences[selectedTravelPreference.value!] : null,
      },
      'like_to_do': {
        'selected_options': selectedLikeToDoOptions.map((category, indices) => 
          MapEntry(category, indices.map((index) => likeToDoOptions[category]![index]).toList())
        ),
      },
    };
    AppLogger.debug('🧩 Prepared profile payload overview: email=${payload['email']}, sections=${payload.keys.where((k) => k != 'email').length}');
    return payload;
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
      Get.snackbar('Validation Error', 'Please complete faith and beliefs section',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    // Habits validation
    if (!areHabitsCompleted) {
      Get.snackbar('Validation Error', 'Please complete habits section',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    // Inspire validation
    if (!isInspireButtonEnabled) {
      Get.snackbar('Validation Error', 'Please select at least 3 traits',
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
      Get.snackbar('Validation Error', 'Please complete lifestyle section',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    // Like to do validation
    if (!isLikeToDoCompleted) {
      Get.snackbar('Validation Error', 'Please complete likes and interests section',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    
    return true;
  }
  
  // =========================================
  // LIFECYCLE METHODS
  // =========================================
  @override
  void onInit() {
    super.onInit();
    loadUserData();
    AppLogger.info('👤 AccountsController onInit - tokenLoaded: ${LocalStorage.token.isNotEmpty}');
    
    // Sync text input to Rx values for personal info
    firstNameController.addListener(() => updateFirstName(firstNameController.text));
    lastNameController.addListener(() => updateLastName(lastNameController.text));
    ageController.addListener(() => updateAge(ageController.text));
    
    // Add listeners for text controllers
    heightController.addListener(validateHeightWeightInputs);
    weightController.addListener(validateHeightWeightInputs);
    
    educationController.addListener(validateEducationInputs);
    jobStatusController.addListener(validateEducationInputs);
    incomeController.addListener(validateEducationInputs);

    // Initialize AccountSetupService if token is available
    if (LocalStorage.token.isNotEmpty) {
      AppLogger.info('🔐 Initializing AccountSetupService from LocalStorage token');
      initializeAccountSetupService(LocalStorage.token);
    }
  }
  
  @override
  void onClose() {
    // Dispose text controllers
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
  
  // =========================================
  // UTILITY METHODS
  // =========================================
  void clearAllData() {
    // Clear personal info
    firstName.value = '';
    lastName.value = '';
    age.value = '';
    
    // Clear selections
    selectedGender.value = '';
    selectedGenders.clear();
    selectedReligionIndex.value = null;
    selectedZodiacIndex.value = null;
    selectedCommunicationStyle.value = null;
    selectedExerciseFrequency.value = null;
    selectedFoodPreference.value = null;
    selectedSocialMediaUsage.value = null;
    selectedSmokingDrinking.value = null;
    selectedTryNewExperiences.value = null;
    selectedDayPreference.value = null;
    selectedLoveLanguage.value = null;
    selectedWeekendActivity.value = null;
    selectedTravelPreference.value = null;
    
    // Clear trait indices
    selectedTraitIndices.clear();
    selectedInterestIndices.clear();
    
    // Clear like to do options
    selectedLikeToDoOptions.forEach((key, value) => value.clear());
    
    // Clear text controllers
    heightController.clear();
    weightController.clear();
    educationController.clear();
    jobStatusController.clear();
    incomeController.clear();
  }
  
  double getCompletionPercentage() {
    int totalSections = 10; // Total number of sections
    int completedSections = 0;
    
    if (firstName.value.isNotEmpty && lastName.value.isNotEmpty && age.value.isNotEmpty) completedSections++;
    if (isGenderSelected) completedSections++;
    if (areHeightWeightValid) completedSections++;
    if (isEducationButtonEnabled.value) completedSections++;
    if (isFaithCompleted) completedSections++;
    if (areHabitsCompleted) completedSections++;
    if (isInspireButtonEnabled) completedSections++;
    if (selectedInterestIndices.isNotEmpty) completedSections++;
    if (isLifestyleCompleted) completedSections++;
    if (isLikeToDoCompleted) completedSections++;
    
    return (completedSections / totalSections) * 100;
  }
}