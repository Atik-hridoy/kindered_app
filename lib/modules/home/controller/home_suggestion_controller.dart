import 'package:get/get.dart';
import 'package:kindered_app/modules/home/models/user_suggestion_model.dart';
import 'package:kindered_app/modules/home/services/user_suggestion_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

class HomeSuggestionController extends GetxController {
  final UserSuggestionService _suggestionService = UserSuggestionService();
  
  // Reactive variables
  final Rx<UserSuggestion?> currentSuggestion = Rx<UserSuggestion?>(null);
  final Rx<UserSuggestionResponse?> currentSuggestionResponse = Rx<UserSuggestionResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Getters for UI - Backward compatibility
  UserSuggestion? get suggestion => currentSuggestion.value;
  bool get hasSuggestion => currentSuggestion.value != null;
  String get imageUrl => currentSuggestion.value?.imageUrl ?? '';
  String get matchPercentage => currentSuggestion.value?.matchPercentage ?? '0%';
  String get name => currentSuggestion.value?.name ?? '';
  String get age => currentSuggestion.value?.age.toString() ?? '';
  String get location => currentSuggestion.value?.location ?? '';
  
  // Getters for comprehensive new data structure
  UserData? get userData => currentSuggestionResponse.value?.data.currentMatch.user;
  CurrentMatch? get currentMatch => currentSuggestionResponse.value?.data.currentMatch;
  bool get hasComprehensiveData => currentSuggestionResponse.value != null;
  
  // Rich data getters for enhanced UI
  List<String>? get userImages => userData?.image;
  String get primaryImage => userData?.primaryImage ?? '';
  String get fullName => userData?.fullName ?? '';
  String get bio => userData?.aboutMe ?? '';
  String get address => userData?.address ?? '';
  int get userAge => userData?.age ?? 0;
  String get gender => userData?.gender ?? '';
  String get bodyImage => userData?.bodyImage ?? '';
  
  // Location data
  String? get locationType => userData?.location.type;
  List<double>? get coordinates => userData?.location.coordinates;
  
  // Body data
  int? get heightCm => userData?.body.heightCm;
  int? get weightKg => userData?.body.weightKg;
  
  // Education and Job
  String? get educationLevel => userData?.eduJob.educationLevel;
  String? get jobTitle => userData?.eduJob.jobTitle;
  int? get annualIncome => userData?.eduJob.annualIncome;
  
  // Interests
  List<String>? get allInterests => userData?.interests.allInterests;
  List<String>? get hobbies => userData?.interests.hobbies;
  List<String>? get creativeOutlets => userData?.interests.creativeOutlets;
  List<String>? get musicGenres => userData?.interests.musicGenres;
  List<String>? get fitnessAndSports => userData?.interests.fitnessAndSports;
  List<String>? get entertainment => userData?.interests.entertainment;
  List<String>? get leisureActivities => userData?.interests.leisureActivities;
  List<String>? get healthAndWellness => userData?.interests.healthAndWellness;
  List<String>? get readingAndContent => userData?.interests.readingAndContent;
  
  // Lifestyle
  String? get sleepingStyle => userData?.lifestyle.sleepingStyle;
  String? get loveStyle => userData?.lifestyle.loveStyle;
  String? get weekends => userData?.lifestyle.weekends;
  String? get traveling => userData?.lifestyle.traveling;
  String? get homeEnvironment => userData?.lifestyle.homeEnvironment;
  String? get livingSpace => userData?.lifestyle.livingSpace;
  
  // Match details
  int get matchScore => currentMatch?.matchScore ?? 0;
  List<String>? get commonInterests => currentMatch?.commonInterests;
  List<String>? get matchReasons => currentMatch?.reasons;
  int get distance => currentMatch?.distance ?? 0;
  
  // Get valid image URL with fallback logic
  String getValidImageUrl() {
    // Try body image first
    if (bodyImage.isNotEmpty && _isValidImageUrl(bodyImage)) {
      return bodyImage;
    }
    
    // Try primary image
    if (primaryImage.isNotEmpty && _isValidImageUrl(primaryImage)) {
      return primaryImage;
    }
    
    // Try regular image URL from backward compatibility
    if (imageUrl.isNotEmpty && _isValidImageUrl(imageUrl)) {
      return imageUrl;
    }
    
    // Try any image from the images list
    if (userImages != null && userImages!.isNotEmpty) {
      for (String img in userImages!) {
        if (_isValidImageUrl(img)) {
          return img;
        }
      }
    }
    
    // Fallback to empty string for dynamic views
    return '';
  }
  
  // Validate if URL is not a placeholder/invalid URL
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    // Check for common placeholder/invalid URLs
    final invalidPatterns = [
      'https://via.placeholder.com',
      'https://placeholder.com',
      'http://placeholder.com',
      'data:image', // base64 placeholder
      'null',
      'undefined',
    ];
    
    // More specific placeholder patterns that are clearly not real images
    final placeholderPatterns = [
      RegExp(r'https?://(?:www\.)?placeholder\.com(?:/.*)?'),
    ];
    
    final lowerUrl = url.toLowerCase();
    
    // Check against simple invalid patterns
    for (String pattern in invalidPatterns) {
      if (lowerUrl.contains(pattern)) {
        return false;
      }
    }
    
    // Check against more specific placeholder patterns
    for (RegExp pattern in placeholderPatterns) {
      if (pattern.hasMatch(lowerUrl)) {
        return false;
      }
    }
    
    // Basic URL validation
    return url.startsWith('http://') || url.startsWith('https://');
  }
  
  @override
  void onInit() {
    super.onInit();
    _loadCurrentMatch();
  }
  
  /// Load current match from API
  Future<void> _loadCurrentMatch() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    AppLogger.info('=== HOME SUGGESTION CONTROLLER - LOADING CURRENT MATCH ===');
    AppLogger.info('Starting to load current match from API...');
    
    try {
      // Use legacy method for backward compatibility
      final currentMatch = await _suggestionService.getCurrentMatchLegacy();
      
      AppLogger.info('API Response Received:');
      AppLogger.info('Current Match: $currentMatch');
      
      if (currentMatch != null) {
        currentSuggestion.value = currentMatch;
        
       
        
      } else {
        errorMessage.value = 'No match available';
        AppLogger.warning('No match available from API');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load match';
      AppLogger.error('Error loading current match: $e');
    } finally {
      isLoading.value = false;
      AppLogger.info('Current match loading completed. Loading state: ${isLoading.value}');
    }
  }
  
  /// Refresh current match
  Future<void> refreshCurrentMatch() async {
    await _loadCurrentMatch();
  }
  
  /// Legacy method for backward compatibility
  Future<void> refreshSuggestions() async {
    await refreshCurrentMatch();
  }
}
