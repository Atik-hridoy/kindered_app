import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../services/ai_assistent_service.dart';
import '../models/ai_assistent_get_model.dart';


class AiAssistentController extends GetxController {
  final TextEditingController messageController = TextEditingController(); 
  final FocusNode messageFocusNode = FocusNode();  
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs; 
  final RxBool isLoading = false.obs;  
  final RxBool isSendButtonEnabled = false.obs;


  late AiAssistentService _aiService; 
  final Rx<MatchmakingResponse?> matchmakingData = Rx<MatchmakingResponse?>(null);
  final RxString errorMessage = ''.obs; 
  final RxString sessionId = ''.obs;  
  final RxBool isConnected = true.obs;  
  final RxInt retryCount = 0.obs; 
  static const int maxRetryAttempts = 3;
  
  final RxBool isAiTyping = false.obs;
  final Rx<DateTime> lastActivity = DateTime.now().obs;
  final RxList<String> quickQuestions = <String>[].obs;
  final RxBool isQuickQuestionsLoading = false.obs;
  final RxString quickQuestionsError = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    _aiService = AiAssistentService();
    messageController.addListener(() {
      isSendButtonEnabled.value = messageController.text.trim().isNotEmpty;
    });
    
    _loadMatchmakingData();
    _loadQuickQuestions();
  }
  
  @override
  void onClose() {
    messageController.dispose();
    messageFocusNode.dispose();
    super.onClose();
  }
  

  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;
    
    messages.add({
      'text': messageText,
      'isMe': true,
      'timestamp': DateTime.now(),
    });
    
    messageController.clear();
    
    _sendAIMessage(messageText);
  }
  
  Future<void> _loadMatchmakingData() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      updateConnectionStatus(true);
      
      final response = await _aiService.getMatchmakingData();
      matchmakingData.value = response;
      
      if (response.data?.sessionId != null) {
        sessionId.value = response.data!.sessionId;
      }
      
      updateLastActivity();
      
      resetRetryCount();
      
      final data = response.data;
      if (data != null && data.messages.isNotEmpty) {
        final firstMessage = data.messages.first;
        _addAIMessage(firstMessage.message, matchData: firstMessage.matchData);
      }
      
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      AppLogger.error('Network error in matchmaking data', e, e.stackTrace);
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to load matchmaking data: ${e.toString()}';
      AppLogger.error('Failed to load matchmaking data', e, stackTrace);
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
      AppLogger.error('Network error in AI chat', e, e.stackTrace);
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to send message: ${e.toString()}';
      _addAIMessage('Sorry, I encountered an error. Please try again.');
      AppLogger.error('Error in AI chat', e, stackTrace);
    } finally {
      isLoading.value = false;
      stopAiTyping(); // Hide typing indicator
    }
  }
  
  /// Add AI message to chat
  void _addAIMessage(String text, {MatchData? matchData}) {
    messages.add({
      'text': text,
      'isMe': false,
      'timestamp': DateTime.now(),
      'matchData': matchData,
    });
  }
  
  
  void clearMessages() {
    messages.clear();
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
  int get matchDistance => currentMatch?.distance.toInt() ?? 0;
  
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

  /// Load quick questions from API
  Future<void> _loadQuickQuestions() async {
    try {
      isQuickQuestionsLoading.value = true;
      quickQuestionsError.value = '';
      updateConnectionStatus(true);
      
      final questions = await _aiService.getQuickQuestions();
      quickQuestions.value = questions;
      
      // If no questions returned, use default questions
      if (questions.isEmpty) {
        quickQuestions.value = [
          'Give me a romantic date idea!',
          "What's my love compatibility?",
        ];
      }
      
      AppLogger.success('✅ Quick questions loaded successfully');
      
    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      quickQuestionsError.value = 'Network error: ${e.message ?? 'Connection failed'}';
      
      // Use default questions on error
      quickQuestions.value = [
        'Give me a romantic date idea!',
        "What's my love compatibility?",
      ];
      
      AppLogger.error('Network error in quick questions', e, e.stackTrace);
    } catch (e, stackTrace) {
      quickQuestionsError.value = 'Failed to load quick questions: ${e.toString()}';
      
      // Use default questions on error
      quickQuestions.value = [
        'Give me a romantic date idea!',
        "What's my love compatibility?",
      ];
      
      AppLogger.error('Failed to load quick questions', e, stackTrace);
    } finally {
      isQuickQuestionsLoading.value = false;
    }
  }

  /// Refresh quick questions
  Future<void> refreshQuickQuestions() async {
    await _loadQuickQuestions();
  }

  /// Clear quick questions error
  void clearQuickQuestionsError() {
    quickQuestionsError.value = '';
  }

  /// Process a quick question and get formatted response
  Future<void> processQuickQuestion(String question) async {
    try {
      // Show loading state
      startAiTyping();
      updateConnectionStatus(true);
      clearError();

      // Add user question to chat
      messages.add({
        'text': question,
        'isMe': true,
        'timestamp': DateTime.now(),
      });

      // Process the quick question
      final response = await _aiService.processQuickQuestion(question: question);

      // Add AI response to chat
      if (response['data'] != null) {
        _addAIMessage(response['data']);
      } else if (response['message'] != null) {
        _addAIMessage(response['message']);
      } else {
        _addAIMessage('Quick question processed successfully!');
      }

      // Update last activity
      updateLastActivity();
      resetRetryCount();

      AppLogger.success('✅ Quick question processed and response displayed');

    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      _addAIMessage('Sorry, I encountered a network error while processing your question. Please try again.');
      
      AppLogger.error('Network error in quick question processing', e, e.stackTrace);
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to process quick question: ${e.toString()}';
      _addAIMessage('Sorry, I encountered an error while processing your question. Please try again.');
      
      AppLogger.error('Failed to process quick question', e, stackTrace);
    } finally {
      stopAiTyping();
    }
  }

  /// Handle Discover button action
  Future<void> discoverMatch() async {
    try {
      // Show loading state
      startAiTyping();
      updateConnectionStatus(true);
      clearError();

      // Add user action to chat
      _addUserMessage('I want to discover more about this match!');

      // Process discover action
      final response = await _aiService.processDiscoverAction();

      // Add AI response to chat
      if (response['data'] != null) {
        _addAIMessage(response['data']);
      } else if (response['message'] != null) {
        _addAIMessage(response['message']);
      } else {
        _addAIMessage('Great! Here are more details about your match. Let me know what you think!');
      }

      // Update last activity
      updateLastActivity();
      resetRetryCount();

      AppLogger.success('✅ Discover action processed successfully');

    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      _addAIMessage('Sorry, I encountered a network error while processing your discovery request. Please try again.');
      
      AppLogger.error('Network error in discover action', e, e.stackTrace);
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to process discover action: ${e.toString()}';
      _addAIMessage('Sorry, I encountered an error while processing your discovery request. Please try again.');
      
      AppLogger.error('Failed to process discover action', e, stackTrace);
    } finally {
      stopAiTyping();
    }
  }

  /// Handle Pass button action
  Future<void> passMatch() async {
    try {
      // Show loading state
      startAiTyping();
      updateConnectionStatus(true);
      clearError();

      // Add user action to chat
      _addUserMessage('I\'d like to pass on this match.');

      // Process pass action
      final response = await _aiService.processPassAction();

      // Add AI response to chat - extract message from data.message
      if (response['data'] != null && response['data']['message'] != null) {
        _addAIMessage(response['data']['message']);
      } else if (response['message'] != null) {
        _addAIMessage(response['message']);
      } else {
        _addAIMessage('No problem! I understand this match wasn\'t quite right for you. Your next curated match will arrive soon!');
      }

      // Update last activity
      updateLastActivity();
      resetRetryCount();

      // Check if response contains new match data
      if (response['data'] != null && response['data']['currentMatch'] != null) {
        // Update matchmaking data with the new match from response
        final newMatchmakingData = MatchmakingResponse.fromJson(response);
        matchmakingData.value = newMatchmakingData;
      } else {
        // Refresh matchmaking data to get the next match
        await refreshMatchmakingData();
      }

      AppLogger.success('✅ Pass action processed successfully');

    } on DioException catch (e) {
      // Handle network errors specifically
      if (e.type == DioExceptionType.connectionError || 
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        updateConnectionStatus(false);
      }
      
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
      _addAIMessage('Sorry, I encountered a network error while processing your pass request. Please try again.');
      
      AppLogger.error('Network error in pass action', e, e.stackTrace);
    } catch (e, stackTrace) {
      errorMessage.value = 'Failed to process pass action: ${e.toString()}';
      _addAIMessage('Sorry, I encountered an error while processing your pass request. Please try again.');
      
      AppLogger.error('Failed to process pass action', e, stackTrace);
    } finally {
      stopAiTyping();
    }
  }

  /// Add user message to chat
  void _addUserMessage(String text) {
    messages.add({
      'text': text,
      'isMe': true,
      'timestamp': DateTime.now(),
    });
  }
}
