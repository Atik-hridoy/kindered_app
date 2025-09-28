import 'package:get/get.dart';
import 'package:kindered_app/modules/home/models/user_suggestion_model.dart';
import 'package:kindered_app/modules/home/services/user_suggestion_service.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../models/ai_assistent_get_model.dart' as ai_models;
import '../controller/ai_assistent_controller.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/config/app_routes.dart';

class HomeSuggestionController extends GetxController {
  final UserSuggestionService _suggestionService = UserSuggestionService();
  late AiAssistentController _aiController;
  
  // Reactive variables
  final Rx<UserSuggestion?> currentSuggestion = Rx<UserSuggestion?>(null);
  final Rx<UserSuggestionResponse?> currentSuggestionResponse = Rx<UserSuggestionResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isUsingAiData = false.obs;
  
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
      final url = _prependBaseUrlIfNeeded(bodyImage);
      AppLogger.info('=== HOME SUGGESTION - Using body image: $url ===');
      return url;
    }
    
    // Try primary image
    if (primaryImage.isNotEmpty && _isValidImageUrl(primaryImage)) {
      final url = _prependBaseUrlIfNeeded(primaryImage);
      AppLogger.info('=== HOME SUGGESTION - Using primary image: $url ===');
      return url;
    }
    
    // Try regular image URL from backward compatibility
    if (imageUrl.isNotEmpty && _isValidImageUrl(imageUrl)) {
      final url = _prependBaseUrlIfNeeded(imageUrl);
      AppLogger.info('=== HOME SUGGESTION - Using legacy image URL: $url ===');
      return url;
    }
    
    // Try any image from the images list
    if (userImages != null && userImages!.isNotEmpty) {
      for (String img in userImages!) {
        if (_isValidImageUrl(img)) {
          final url = _prependBaseUrlIfNeeded(img);
          AppLogger.info('=== HOME SUGGESTION - Using image from list: $url ===');
          return url;
        }
      }
    }
    
    // Return empty string - CustomPhotoCard will handle the placeholder
    AppLogger.info('=== HOME SUGGESTION - No valid image found, returning empty string ===');
    return '';
  }
  
  // Prepend base URL for relative paths
  String _prependBaseUrlIfNeeded(String url) {
    if (url.startsWith('/')) {
      return '${AppUrls.imageUrl}$url';
    }
    return url;
  }
  
  // Validate if URL is not a placeholder/invalid URL
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    
    // Check for common placeholder/invalid URLs
    final invalidPatterns = [
      'https://via.placeholder.com',
      'https://placeholder.com',
      'http://placeholder.com',
      'data:image', 
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
    
    // Basic URL validation - accept both network URLs and file URIs
    return url.startsWith('http://') || 
           url.startsWith('https://') || 
           url.startsWith('file://');
  }
  
  @override
  void onInit() {
    super.onInit();
    
    // Get AiAssistentController instance
    _aiController = Get.find<AiAssistentController>();
    
    // Listen to AI controller changes
    ever(_aiController.matchmakingData, _updateFromAiData);
    
    // Load initial data
    _loadCurrentMatch();
  }
  
  /// Update data from AiAssistentController
  Future<void> _updateFromAiData(ai_models.MatchmakingResponse? aiData) async {
    if (aiData == null || aiData.data?.currentMatch == null) {
      AppLogger.info('=== HOME SUGGESTION - AI DATA UPDATE: No AI data available ===');
      isUsingAiData.value = false;
      return;
    }
    
    AppLogger.info('=== HOME SUGGESTION - AI DATA UPDATE: Syncing from AI Assistant ===');
    
    try {
      final aiCurrentMatch = aiData.data!.currentMatch;
      final aiUser = aiCurrentMatch.user;
      
      // Convert AI data to UserSuggestion format for backward compatibility
      final userSuggestion = UserSuggestion(
        id: aiUser.id,
        name: '${aiUser.firstName} ${aiUser.lastName}',
        age: aiUser.age,
        imageUrl: aiUser.headShotImage.isNotEmpty ? aiUser.headShotImage : 
                 (aiUser.image.isNotEmpty ? aiUser.image.first : ''),
        matchPercentage: '${aiCurrentMatch.matchScore}%',
        location: 'Distance: ${aiCurrentMatch.distance}km',
        images: aiUser.image.cast<String>(),
      );
      
      // Update reactive variables
      currentSuggestion.value = userSuggestion;
      isUsingAiData.value = true;
      
      // Save current user ID to local storage
      await _saveCurrentUserIdToStorage();
      
      AppLogger.info('=== HOME SUGGESTION - AI DATA SYNC COMPLETED ===');
      AppLogger.info('Synced user: ${userSuggestion.name}, Age: ${userSuggestion.age}');
      AppLogger.info('Match Score: ${aiCurrentMatch.matchScore}%, Distance: ${aiCurrentMatch.distance}km');
      
    } catch (e, stackTrace) {
      AppLogger.error('Error syncing AI data to HomeSuggestionController', e, stackTrace);
      isUsingAiData.value = false;
    }
  }
  
  /// Load current match from API (fallback when AI data is not available)
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
        isUsingAiData.value = false;
        
        // Save current user ID to local storage
        await _saveCurrentUserIdToStorage();
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

  /// Save current suggestion user ID to local storage
  Future<void> _saveCurrentUserIdToStorage() async {
    try {
      String currentUserId = '';
      
      // Try to get user ID from comprehensive data structure first
      if (hasComprehensiveData && userData?.id.isNotEmpty == true) {
        currentUserId = userData!.id;
      } 
      // Fallback to backward compatibility structure
      else if (hasSuggestion && currentSuggestion.value?.id.isNotEmpty == true) {
        currentUserId = currentSuggestion.value!.id;
      }
      
      if (currentUserId.isNotEmpty) {
        await LocalStorage.setString('current_suggestion_user_id', currentUserId);
        AppLogger.info('=== HOME SUGGESTION - Saved current user ID to storage: $currentUserId ===');
      } else {
        AppLogger.info('=== HOME SUGGESTION - No user ID available to save ===');
      }
    } catch (e) {
      AppLogger.error('=== HOME SUGGESTION - Error saving user ID to storage: $e ===');
    }
  }

  /// Get saved current user ID from local storage (for testing)
  Future<String> getSavedUserId() async {
    try {
      final savedUserId = await LocalStorage.getString('current_suggestion_user_id');
      AppLogger.info('=== HOME SUGGESTION - Retrieved saved user ID: $savedUserId ===');
      return savedUserId;
    } catch (e) {
      AppLogger.error('=== HOME SUGGESTION - Error retrieving saved user ID: $e ===');
      return '';
    }
  }

  /// Navigate to chat view with current user data
  void navigateToChat({String? chatId, String? participantName, String? participantId}) {
    // Get current user ID from LocalStorage
    final currentUserId = LocalStorage.userId;
    
    // Get suggested user data from current suggestion
    final suggestedUserId = userData?.id ?? currentSuggestion.value?.id ?? '';
    final suggestedUserName = fullName.isNotEmpty ? fullName : (name.isNotEmpty ? name : 'Unknown');
    final suggestedUserAge = userAge > 0 ? userAge.toString() : (age.isNotEmpty ? age : '0');
    
    // Determine the final chat ID to be used
    // Only use chatId if it's provided and valid, otherwise let ChatController create new chat
    final finalChatId = (chatId != null && chatId.isNotEmpty && chatId != suggestedUserId) ? chatId : null;
    
    AppLogger.info('=== HOME SUGGESTION - NAVIGATE TO CHAT ===');
    AppLogger.info('🏠 HOME TO CHAT NAVIGATION STARTED ===');
    AppLogger.info('📋 Input Parameters:');
    AppLogger.info('  - chatId (input): $chatId');
    AppLogger.info('  - participantName (input): $participantName');
    AppLogger.info('  - participantId (input): $participantId');
    AppLogger.info('👤 User Data:');
    AppLogger.info('  - Current User ID: $currentUserId');
    AppLogger.info('  - Suggested User ID: $suggestedUserId');
    AppLogger.info('  - Suggested User Name: $suggestedUserName');
    AppLogger.info('  - Suggested User Age: $suggestedUserAge');
    AppLogger.info('🆔 Chat ID Resolution:');
    AppLogger.info('  - Final Chat ID: $finalChatId');
    AppLogger.info('  - Chat ID Source: ${finalChatId != null ? 'Using existing chat ID' : 'Will create new chat'}');
    
    // Prepare navigation arguments
    final navigationArgs = {
      'chatId': finalChatId, // Will be null for new chats
      'currentUserId': currentUserId,
      'participantName': participantName ?? suggestedUserName,
      'participantId': participantId ?? suggestedUserId, // This should be the other user's ID
    };
    
    AppLogger.info('🚀 Navigation Arguments:');
    navigationArgs.forEach((key, value) {
      AppLogger.info('  - $key: $value');
    });
    
    AppLogger.info('🎯 Navigating to: ${AppRoutes.chat}');
    AppLogger.info('=== HOME TO CHAT NAVIGATION COMPLETED ===');
    
    // Navigate to chat view with both user IDs and suggested user data
    // The ChatController will automatically create the chat using CreateChatService
    Get.toNamed(AppRoutes.chat, arguments: navigationArgs);
  }
}
