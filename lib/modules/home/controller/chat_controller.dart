import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../services/create_chat_service.dart';
import '../models/create_chat.dart';
import 'package:dio/dio.dart';

class ChatController extends GetxController {
  final CreateChatService _createChatService = CreateChatService(Dio());
  
  // Reactive variables
  final Rx<CreateChatResponse?> chatResponse = Rx<CreateChatResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString participantName = ''.obs;
  final RxString participantId = ''.obs;
  final RxString currentUserId = ''.obs;
  
  // Getters
  bool get hasChat => chatResponse.value != null;
  String get chatId => chatResponse.value?.data.id ?? '';
  List<String> get participants => chatResponse.value?.data.participants ?? [];
  
  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
  }
  
  /// Initialize controller data from navigation arguments
  void _initializeFromArguments() {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        participantName.value = arguments['participantName'] ?? '';
        participantId.value = arguments['participantId'] ?? '';
        currentUserId.value = arguments['currentUserId'] ?? LocalStorage.userId;
        
        AppLogger.info('=== CHAT CONTROLLER - INITIALIZED ===');
        AppLogger.info('Participant Name: ${participantName.value}');
        AppLogger.info('Participant ID: ${participantId.value}');
        AppLogger.info('Current User ID: ${currentUserId.value}');
        
        // If we have participant ID, create chat automatically
        if (participantId.value.isNotEmpty && currentUserId.value.isNotEmpty) {
          _createChatWithParticipant();
        }
      }
    } catch (e) {
      AppLogger.error('Error initializing chat controller: $e');
      errorMessage.value = 'Failed to initialize chat';
    }
  }
  
  /// Create chat with the participant
  Future<void> _createChatWithParticipant() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    AppLogger.info('=== CHAT CONTROLLER - CREATING CHAT ===');
    AppLogger.info('Creating chat between ${currentUserId.value} and ${participantId.value}');
    
    try {
      final response = await _createChatService.createChatWithSuggestedUser(
        suggestedUserId: participantId.value,
      );
      
      chatResponse.value = response;
      
      AppLogger.info('Chat created successfully!');
      AppLogger.info('Chat ID: ${response.data.id}');
      AppLogger.info('Participants: ${response.data.participants}');
      
    } catch (e) {
      AppLogger.error('Error creating chat: $e');
      errorMessage.value = 'Failed to create chat: $e';
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Retry creating chat
  Future<void> retryCreateChat() async {
    await _createChatWithParticipant();
  }
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
  
  /// Get chat display name
  String getChatDisplayName() {
    return participantName.value.isNotEmpty ? participantName.value : 'Unknown';
  }
  
  /// Check if current user is in participants
  bool isCurrentUserInChat() {
    return participants.contains(currentUserId.value);
  }
}
