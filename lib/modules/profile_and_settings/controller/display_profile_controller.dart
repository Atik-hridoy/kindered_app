import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/display_profile.dart';
import 'package:kindered_app/modules/profile_and_settings/services/profile_service.dart';

class DisplayProfileController extends GetxController {
  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Current match data
  final Rx<CurrentMatchsResponse?> currentMatchResponse = Rx<CurrentMatchsResponse?>(null);
  final Rx<MatchUser?> currentUser = Rx<MatchUser?>(null);
  final Rx<CurrentMatch?> currentMatch = Rx<CurrentMatch?>(null);
  
  // Profile service
  late ProfileService _profileService;
  
  // Computed getters for easy access to user data
  String get name => currentUser.value?.firstName ?? '';
  String get fullName => '${currentUser.value?.firstName ?? ''} ${currentUser.value?.lastName ?? ''}'.trim();
  int get age => currentUser.value?.age ?? 0;
  String get bio => currentUser.value?.aboutMe ?? '';
  String get jobTitle => currentUser.value?.eduJob.jobTitle ?? '';
  String get education => currentUser.value?.eduJob.educationLevel ?? '';
  String get height => '${currentUser.value?.body.heightCm ?? 0} cm';
  String get weight => '${currentUser.value?.body.weightKg ?? 0} kg';
  String get location => 'Distance: ${currentMatch.value?.distance.toStringAsFixed(1) ?? 0} km';
  String get religion => currentUser.value?.religion ?? '';
  String get zodiacSign => currentUser.value?.zodiacSign ?? '';
  int get matchScore => currentMatch.value?.matchScore ?? 0;
  bool get isVerified => currentUser.value?.isVerified ?? false;
  int get profileCompletionPercentage => currentUser.value?.profileCompletionPercentage ?? 0;
  
  // Interests
  List<String> get interests {
    final user = currentUser.value;
    if (user == null) return [];
    
    return [
      ...user.interests.hobbies,
      ...user.interests.creativeOutlets,
      ...user.interests.fitnessAndSports,
      ...user.interests.entertainment,
      ...user.interests.leisureActivities,
      ...user.interests.musicGenres,
      ...user.interests.healthAndWellness,
      ...user.interests.readingAndContent,
    ];
  }
  
  // Lifestyle
  String get sleepingStyle => currentUser.value?.lifestyle.sleepingStyle ?? '';
  String get loveStyle => currentUser.value?.lifestyle.loveStyle ?? '';
  String get weekends => currentUser.value?.lifestyle.weekends ?? '';
  String get traveling => currentUser.value?.lifestyle.traveling ?? '';
  String get homeEnvironment => currentUser.value?.lifestyle.homeEnvironment ?? '';
  String get livingSpace => currentUser.value?.lifestyle.livingSpace ?? '';
  
  // Habits
  List<String> get communicationStyle => currentUser.value?.habits.communicationStyle ?? [];
  String get workout => currentUser.value?.habits.workout ?? '';
  List<String> get eatingStyle => currentUser.value?.habits.eatingStyle ?? [];
  String get socialMedia => currentUser.value?.habits.socialMedia ?? '';
  String get smokeOrDrink => currentUser.value?.habits.smokeOrDrink ?? '';
  String get newExperiences => currentUser.value?.habits.newExercise ?? '';
  
  // Personal traits
  List<String> get personalTraits => currentUser.value?.personalTraitsInspire ?? [];
  
  // Common interests with current user
  List<String> get commonInterests => currentMatch.value?.commonInterests ?? [];
  
  // Match reasons
  List<String> get matchReasons => currentMatch.value?.reasons ?? [];
  
  // Gallery images
  List<String> get galleryImages {
    final user = currentUser.value;
    if (user == null) return [];
    
    List<String> images = [];
    
    // Add specific images if they exist
    if (user.bodyImage.isNotEmpty) images.add(_getFullImageUrl(user.bodyImage));
    if (user.headShotImage.isNotEmpty) images.add(_getFullImageUrl(user.headShotImage));
    if (user.personalityImage.isNotEmpty) images.add(_getFullImageUrl(user.personalityImage));
    
    // Add gallery images
    if (user.image.isNotEmpty) {
      images.addAll(user.image.map((img) => _getFullImageUrl(img)));
    }
    
    // Filter out empty or invalid URLs
    return images.where((url) => url.isNotEmpty && _isValidImageUrl(url)).toList();
  }
  
  // Helper method to get full image URL
  String _getFullImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    
    // If it's already a full URL, return as is
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }
    
    // Remove leading slash if present
    final cleanPath = imagePath.startsWith('/') ? imagePath.substring(1) : imagePath;
    
    // Combine with base image URL
    return '${AppUrls.imageUrl}/$cleanPath';
  }
  
  // Helper method to validate image URLs
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    // Check for placeholder URLs
    final placeholderPatterns = [
      'example.com',
      'placeholder.com',
      'via.placeholder.com',
      'picsum.photos/seed',
      'default.jpg',
      'placeholder.jpg',
    ];
    
    final lowerUrl = url.toLowerCase();
    return !placeholderPatterns.any((pattern) => lowerUrl.contains(pattern));
  }
  
  @override
  void onInit() {
    super.onInit();
    _initializeProfileService();
    
    // Check if we received arguments from AI assistant view
    if (Get.arguments != null) {
      final arguments = Get.arguments as Map<String, dynamic>;
      if (arguments['currentMatch'] != null && arguments['user'] != null) {
        // Use the passed data instead of fetching from API
        currentMatch.value = arguments['currentMatch'];
        currentUser.value = arguments['user'];
        AppLogger.info('✅ [DISPLAY PROFILE] Using data from AI assistant view');
        AppLogger.info('👤 [DISPLAY PROFILE] User: $fullName, Age: $age');
        AppLogger.info('💯 [DISPLAY PROFILE] Match Score: $matchScore%');
        return;
      }
    }
    
    // Fallback to fetching from API if no arguments provided
    fetchCurrentMatch();
  }
  
  /// Initialize the profile service
  void _initializeProfileService() {
    if (LocalStorage.token.isNotEmpty) {
      _profileService = ProfileService(LocalStorage.token);
      AppLogger.info('🔐 [DISPLAY PROFILE] ProfileService initialized with token');
    } else {
      AppLogger.error('❌ [DISPLAY PROFILE] Cannot initialize ProfileService - no token found');
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
    }
  }
  
  /// Fetch current match data from API
  Future<void> fetchCurrentMatch() async {
    if (LocalStorage.token.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
      return;
    }
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      AppLogger.info('🔄 [DISPLAY PROFILE] Fetching current match data...');
      
      final response = await _profileService.getCurrentMatch();
      
      currentMatchResponse.value = response;
      currentUser.value = response.data.currentMatch.user;
      currentMatch.value = response.data.currentMatch;
      
      AppLogger.info('✅ [DISPLAY PROFILE] Current match data loaded successfully');
      AppLogger.info('👤 [DISPLAY PROFILE] User: $fullName, Age: $age');
      AppLogger.info('💯 [DISPLAY PROFILE] Match Score: $matchScore%');
      
    } catch (e) {
      AppLogger.error('❌ [DISPLAY PROFILE] Error fetching current match: $e');
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Retry fetching current match data
  Future<void> retryFetch() async {
    await fetchCurrentMatch();
  }
  
  /// Get formatted height in feet and inches
  String getFormattedHeight() {
    final heightCm = currentUser.value?.body.heightCm ?? 0;
    
    final totalInches = (heightCm * 0.393701).round();
    final feet = totalInches ~/ 12;
    final inches = totalInches % 12;
    
    return '$feet\'$inches"';
  }
  
  /// Get formatted income
  String getFormattedIncome() {
    final income = currentUser.value?.eduJob.annualIncome ?? 0;
    
    if (income >= 1000000) {
      return '\$${(income / 1000000).toStringAsFixed(1)}M';
    } else if (income >= 1000) {
      return '\$${(income / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$$income';
    }
  }
  
  /// Check if user has specific interest
  bool hasInterest(String interest) {
    return interests.contains(interest);
  }
  
  /// Check if user has specific trait
  bool hasTrait(String trait) {
    return personalTraits.contains(trait);
  }
}