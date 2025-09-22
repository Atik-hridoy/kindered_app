import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/modules/home/models/user_suggestion_model.dart';
import 'package:kindered_app/modules/home/services/user_suggestion_service.dart';

class HomeSuggestionController extends GetxController {
  final UserSuggestionService _suggestionService = UserSuggestionService(Dio());
  
  // Reactive variables
  final Rx<UserSuggestion?> currentSuggestion = Rx<UserSuggestion?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Getters for UI
  UserSuggestion? get suggestion => currentSuggestion.value;
  bool get hasSuggestion => currentSuggestion.value != null;
  String get imageUrl => currentSuggestion.value?.imageUrl ?? '';
  String get matchPercentage => currentSuggestion.value?.matchPercentage ?? '0%';
  String get name => currentSuggestion.value?.name ?? '';
  String get age => currentSuggestion.value?.age.toString() ?? '';
  String get location => currentSuggestion.value?.location ?? '';
  
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
    
    try {
      AppLogger.info('🔄 [HOME CONTROLLER] Loading current match...');
      
      final currentMatch = await _suggestionService.getCurrentMatch();
      
      if (currentMatch != null) {
        currentSuggestion.value = currentMatch;
        AppLogger.info('✅ [HOME CONTROLLER] Current match loaded successfully');
        AppLogger.info('👤 [HOME CONTROLLER] Current match: ${currentSuggestion.value?.name}');
      } else {
        AppLogger.warning('⚠️ [HOME CONTROLLER] No current match found');
        errorMessage.value = 'No match available';
      }
    } catch (e) {
      AppLogger.error('❌ [HOME CONTROLLER] Failed to load current match: $e');
      errorMessage.value = 'Failed to load match';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Load next match suggestion
  Future<void> loadNextMatch() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      AppLogger.info('🔄 [HOME CONTROLLER] Loading next match...');
      
      final nextMatch = await _suggestionService.getNextMatch();
      
      if (nextMatch != null) {
        currentSuggestion.value = nextMatch;
        AppLogger.info('✅ [HOME CONTROLLER] Next match loaded: ${nextMatch.name}');
      } else {
        AppLogger.warning('⚠️ [HOME CONTROLLER] No next match found');
        errorMessage.value = 'No more matches available';
      }
    } catch (e) {
      AppLogger.error('❌ [HOME CONTROLLER] Failed to load next match: $e');
      errorMessage.value = 'Failed to load next match';
    } finally {
      isLoading.value = false;
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
