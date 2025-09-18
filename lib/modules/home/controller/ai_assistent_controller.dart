import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../services/ai_assistent_service.dart';
import '../models/ai_assistent_get_model.dart';

class AiAssistentController extends GetxController {
  // Text controller for message input
  final TextEditingController messageController = TextEditingController();
  
  // Focus node for the text field
  final FocusNode messageFocusNode = FocusNode();
  
  // Observable for messages
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  
  // Observable for loading state
  final RxBool isLoading = false.obs;
  
  // Observable for send button enabled state
  final RxBool isSendButtonEnabled = false.obs;
  
  // AI Assistant Service
  late AiAssistentService _aiService;
  
  // Observable for matchmaking data
  final Rx<MatchmakingResponse?> matchmakingData = Rx<MatchmakingResponse?>(null);
  
  // Observable for API error state
  final RxString errorMessage = ''.obs;
  
  // Session ID for chat continuity
  final RxString sessionId = ''.obs;
  
  // Connection status observable
  final RxBool isConnected = true.obs;
  
  // Retry count for failed requests
  final RxInt retryCount = 0.obs;
  
  // Maximum retry attempts
  static const int maxRetryAttempts = 3;
  
  // Typing indicator for AI responses
  final RxBool isAiTyping = false.obs;
  
  // Last activity timestamp
  final Rx<DateTime> lastActivity = DateTime.now().obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Initialize AI service
    _aiService = AiAssistentService();
    
    // Add listener to text controller to enable/disable send button
    messageController.addListener(() {
      isSendButtonEnabled.value = messageController.text.trim().isNotEmpty;
    });
    
    // Initialize with welcome message
    _addWelcomeMessage();
    
    // Load initial matchmaking data
    _loadMatchmakingData();
  }
  
  @override
  void onClose() {
    messageController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
  
  void _addWelcomeMessage() {
    messages.add({
      'text': 'Looking for someone who loves to cook and enjoy new things',
      'isMe': false,
      'timestamp': DateTime.now(),
    });
  }
  
  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;
    
    // Add user message
    messages.add({
      'text': messageText,
      'isMe': true,
      'timestamp': DateTime.now(),
    });
    
    // Clear input field
    messageController.clear();
    
    // Send message to AI API
    _sendAIMessage(messageText);
  }
  
  /// Load initial matchmaking data from API
  Future<void> _loadMatchmakingData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      updateConnectionStatus(true);
      
      final response = await _aiService.getMatchmakingData();
      matchmakingData.value = response;
      
      // Set session ID from response
      if (response.data?.sessionId != null) {
        sessionId.value = response.data!.sessionId;
      }
      
      // Update last activity
      updateLastActivity();
      
      // Reset retry count on success
      resetRetryCount();
      
      // Add greeting message if available
      final data = response.data;
      if (data != null && data.greeting.isNotEmpty) {
        _addAIMessage(data.greeting);
      }
      
    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      AppLogger.error('Network error in matchmaking data', e);
    } catch (e) {
      errorMessage.value = 'Failed to load matchmaking data: ${e.toString()}';
      AppLogger.error('Failed to load matchmaking data', e);
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Send message to AI API
  Future<void> _sendAIMessage(String messageText) async {
    if (!_aiService.isAuthenticated) {
      _addAIMessage('Please log in to use AI Assistant');
      return;
    }
    
    if (!isSessionValid) {
      // Session expired, create new session
      await _loadMatchmakingData();
    }
    
    try {
      isLoading.value = true;
      startAiTyping(); // Show typing indicator
      errorMessage.value = '';
      updateConnectionStatus(true);
      
      final response = await _aiService.sendChatMessage(
        message: messageText,
        sessionId: sessionId.value.isNotEmpty ? sessionId.value : null,
      );
      
      // Update session ID if provided in response
      if (response['sessionId'] != null) {
        sessionId.value = response['sessionId'];
      }
      
      // Update last activity
      updateLastActivity();
      
      // Reset retry count on success
      resetRetryCount();
      
      // Add AI response to messages
      if (response['response'] != null) {
        _addAIMessage(response['response']);
      }
      
    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      _addAIMessage('Sorry, I\'m having trouble connecting. Please check your internet connection.');
      AppLogger.error('Network error in AI chat', e);
    } catch (e) {
      errorMessage.value = 'Failed to send message: ${e.toString()}';
      _addAIMessage('Sorry, I encountered an error. Please try again.');
      AppLogger.error('Error in AI chat', e);
    } finally {
      isLoading.value = false;
      stopAiTyping(); // Hide typing indicator
    }
  }
  
  /// Add AI message to chat
  void _addAIMessage(String text) {
    messages.add({
      'text': text,
      'isMe': false,
      'timestamp': DateTime.now(),
    });
  }
  
  
  void clearMessages() {
    messages.clear();
    _addWelcomeMessage();
  }
  
  String formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  /// Refresh matchmaking data
  Future<void> refreshMatchmakingData() async {
    await _loadMatchmakingData();
  }
  
  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }
  
  /// Check if user has current match
  bool get hasCurrentMatch => matchmakingData.value?.data?.currentMatch != null;
  
  /// Get current match data
  CurrentMatch? get currentMatch => matchmakingData.value?.data?.currentMatch;
  
  /// Get common interests with current match
  List<String> get commonInterests => currentMatch?.commonInterests ?? [];
  
  /// Get match score
  int get matchScore => currentMatch?.matchScore ?? 0;
  
  /// Get match reasons
  List<String> get matchReasons => currentMatch?.reasons ?? [];
  
  /// Get match distance
  int get matchDistance => currentMatch?.distance ?? 0;
  
  /// Get match user info
  MatchUser? get matchUser => currentMatch?.user;
  
  /// Check if there are more matches available
  bool get hasMoreMatches => matchmakingData.value?.data?.hasMoreMatches ?? false;
  
  /// Check if can retry failed request
  bool get canRetry => retryCount.value < maxRetryAttempts;
  
  /// Get formatted retry message
  String get retryMessage => 'Retry attempt ${retryCount.value + 1} of $maxRetryAttempts';
  
  /// Update connection status
  void updateConnectionStatus(bool connected) {
    isConnected.value = connected;
    if (!connected) {
      errorMessage.value = 'No internet connection. Please check your network.';
    }
  }
  
  /// Reset retry count
  void resetRetryCount() {
    retryCount.value = 0;
  }
  
  /// Retry last failed operation
  Future<void> retryLastOperation() async {
    if (!canRetry) {
      errorMessage.value = 'Maximum retry attempts reached. Please try again later.';
      return;
    }
    
    retryCount.value++;
    clearError();
    
    // Retry the last operation (in this case, load matchmaking data)
    await _loadMatchmakingData();
  }
  
  /// Check session validity
  bool get isSessionValid => sessionId.value.isNotEmpty && lastActivity.value.difference(DateTime.now()).inMinutes < 30;
  
  /// Update last activity timestamp
  void updateLastActivity() {
    lastActivity.value = DateTime.now();
  }
  
  /// Start AI typing indicator
  void startAiTyping() {
    isAiTyping.value = true;
  }
  
  /// Stop AI typing indicator
  void stopAiTyping() {
    isAiTyping.value = false;
  }
  
  /// Get connection status message
  String get connectionStatusMessage {
    if (!isConnected.value) {
      return 'Offline';
    } else if (isLoading.value) {
      return 'Loading...';
    } else if (isAiTyping.value) {
      return 'AI is typing...';
    }
    return 'Online';
  }
  
  /// Get status color based on current state
  Color get statusColor {
    if (!isConnected.value) {
      return Colors.red;
    } else if (isLoading.value || isAiTyping.value) {
      return Colors.orange;
    }
    return Colors.green;
  }
}
