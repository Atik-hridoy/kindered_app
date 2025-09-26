import 'package:get/get.dart';
import 'package:kindered_app/core/utils/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/treamsOfService.dart';
import 'package:kindered_app/modules/profile_and_settings/services/tramsOfService.dart';

class TermsConditionController extends GetxController {
  // Services
  late TermsOfService _termsOfService;
  
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<SettingResponse?> termsResponse = Rx<SettingResponse?>(null);
  final Rx<SettingResponse?> privacyResponse = Rx<SettingResponse?>(null);
  final RxString currentTab = 'terms'.obs; // 'terms' or 'privacy'
  
  @override
  void onInit() {
    super.onInit();
    _initializeService();
    fetchTermsOfService();
    fetchPrivacyPolicy();
  }
  
  /// Initialize the terms of service service
  void _initializeService() {
    if (LocalStorage.token.isNotEmpty) {
      _termsOfService = TermsOfService(LocalStorage.token);
      AppLogger.info('🔐 [TERMS CONDITION] TermsOfService initialized with token');
    } else {
      AppLogger.error('❌ [TERMS CONDITION] Cannot initialize TermsOfService - no token found');
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
    }
  }
  
  /// Fetch Terms of Service content
  Future<void> fetchTermsOfService() async {
    if (LocalStorage.token.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
      return;
    }
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      AppLogger.info('📄 [TERMS CONDITION] Fetching terms of service...');
      
      final response = await _termsOfService.getTermsOfService();
      
      if (response.success) {
        termsResponse.value = response;
        AppLogger.info('✅ [TERMS CONDITION] Terms of service fetched successfully');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        AppLogger.error('❌ [TERMS CONDITION] Failed to fetch terms of service: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred while fetching terms of service';
      AppLogger.error('❌ [TERMS CONDITION] Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Fetch Privacy Policy content
  Future<void> fetchPrivacyPolicy() async {
    if (LocalStorage.token.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
      return;
    }
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      AppLogger.info('🔒 [TERMS CONDITION] Fetching privacy policy...');
      
      final response = await _termsOfService.getPrivacyPolicy();
      
      if (response.success) {
        privacyResponse.value = response;
        AppLogger.info('✅ [TERMS CONDITION] Privacy policy fetched successfully');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        AppLogger.error('❌ [TERMS CONDITION] Failed to fetch privacy policy: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred while fetching privacy policy';
      AppLogger.error('❌ [TERMS CONDITION] Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Switch between tabs
  void switchTab(String tab) {
    if (tab == 'terms' || tab == 'privacy') {
      currentTab.value = tab;
      AppLogger.info('📑 [TERMS CONDITION] Switched to $tab tab');
    }
  }
  
  /// Retry fetching data
  Future<void> retry() async {
    AppLogger.info('🔄 [TERMS CONDITION] Retrying data fetch...');
    await fetchTermsOfService();
    await fetchPrivacyPolicy();
  }
  
  /// Get current content based on active tab
  String get currentContent {
    if (currentTab.value == 'terms') {
      return termsResponse.value?.data ?? 'No terms of service content available.';
    } else {
      return privacyResponse.value?.data ?? 'No privacy policy content available.';
    }
  }
  
  /// Check if current content is loading
  bool get isCurrentLoading {
    return isLoading.value;
  }
  
  /// Check if current content has error
  bool get hasCurrentError {
    return hasError.value;
  }
  
  /// Get current error message
  String get currentErrorMessage {
    return errorMessage.value;
  }
}

class TermsAndConditionsController extends GetxController {
  
}
