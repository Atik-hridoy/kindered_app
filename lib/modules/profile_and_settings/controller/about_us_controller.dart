import 'package:get/get.dart';
import 'package:kindered_app/core/utils/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/modules/profile_and_settings/model/treamsOfService.dart';
import 'package:kindered_app/modules/profile_and_settings/services/aboutus.dart';

class AboutUsController extends GetxController {
  // Services
  late AboutUs _aboutUsService;
  
  // Reactive variables
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<SettingResponse?> aboutUsResponse = Rx<SettingResponse?>(null);
  
  @override
  void onInit() {
    super.onInit();
    _initializeService();
    fetchAboutUs();
  }
  
  /// Initialize the AboutUs service
  void _initializeService() {
    if (LocalStorage.token.isNotEmpty) {
      _aboutUsService = AboutUs(LocalStorage.token);
      AppLogger.info('🔐 [ABOUT US] AboutUs service initialized with token');
    } else {
      AppLogger.error('❌ [ABOUT US] Cannot initialize AboutUs service - no token found');
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
    }
  }
  
  /// Fetch About Us content
  Future<void> fetchAboutUs() async {
    if (LocalStorage.token.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Authentication token not found. Please log in again.';
      return;
    }
    
    try {
      isLoading.value = true;
      hasError.value = false;
      errorMessage.value = '';
      
      AppLogger.info('📄 [ABOUT US] Fetching about us content...');
      
      final response = await _aboutUsService.aboutUs();
      
      if (response.success) {
        aboutUsResponse.value = response;
        AppLogger.info('✅ [ABOUT US] About us content fetched successfully');
      } else {
        hasError.value = true;
        errorMessage.value = response.message;
        AppLogger.error('❌ [ABOUT US] Failed to fetch about us content: ${response.message}');
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'An unexpected error occurred while fetching about us content';
      AppLogger.error('❌ [ABOUT US] Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Retry fetching data
  Future<void> retry() async {
    AppLogger.info('🔄 [ABOUT US] Retrying data fetch...');
    await fetchAboutUs();
  }
  
  /// Get about us content
  String get aboutUsContent {
    return aboutUsResponse.value?.data ?? 'No about us content available.';
  }
  
  /// Check if content is loading
  bool get isCurrentLoading {
    return isLoading.value;
  }
  
  /// Check if content has error
  bool get hasCurrentError {
    return hasError.value;
  }
  
  /// Get current error message
  String get currentErrorMessage {
    return errorMessage.value;
  }
}
