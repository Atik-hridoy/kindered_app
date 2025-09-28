import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../services/ai_assistent_service.dart';
import '../models/ai_assistent_get_model.dart';

class AiAssistentController extends GetxController {
  // UI controllers
  final TextEditingController messageController = TextEditingController();
  final FocusNode messageFocusNode = FocusNode();

  // Chat state
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSendButtonEnabled = false.obs;
  final RxBool isAiTyping = false.obs;

  // Session and matchmaking
  late AiAssistentService _aiService;
  final Rx<MatchmakingResponse?> matchmakingData = Rx<MatchmakingResponse?>(null);
  final RxString sessionId = ''.obs;
  final Rx<DateTime> lastActivity = DateTime.now().obs;

  // Connection and retry
  final RxBool isConnected = true.obs;
  final RxInt retryCount = 0.obs;
  static const int maxRetryAttempts = 3;

  // Errors
  final RxString errorMessage = ''.obs;

  // Quick questions
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

  /// --- Public Actions ---

  void sendMessage() {
    final messageText = messageController.text.trim();
    if (messageText.isEmpty) return;

    _addUserMessage(messageText);
    messageController.clear();

    _sendAIMessage(messageText);
  }

  void clearMessages() => messages.clear();

  Future<void> refreshMatchmakingData() => _loadMatchmakingData();
  Future<void> refreshQuickQuestions() => _loadQuickQuestions();

  void clearError() => errorMessage.value = '';
  void clearQuickQuestionsError() => quickQuestionsError.value = '';

  Future<void> processQuickQuestion(String question) async {
    await _handleUserAction(
      userMessage: question,
      apiCall: () => _aiService.processQuickQuestion(question: question),
      defaultResponse: 'Quick question processed successfully!',
      errorContext: 'quick question',
    );
  }

  Future<void> discoverMatch() async {
    await _handleUserAction(
      userMessage: 'I want to discover more about this match!',
      apiCall: () => _aiService.processDiscoverAction(),
      defaultResponse:
          'Great! Here are more details about your match. Let me know what you think!',
      errorContext: 'discover action',
    );
  }

  Future<void> passMatch() async {
    await _handleUserAction(
      userMessage: 'I\'d like to pass on this match.',
      apiCall: () => _aiService.processPassAction(),
      defaultResponse:
          'No problem! I understand this match wasn\'t quite right for you. Your next curated match will arrive soon!',
      errorContext: 'pass action',
      onSuccess: (response) async {
        if (response['data']?['currentMatch'] != null) {
          matchmakingData.value = MatchmakingResponse.fromJson(response);
        } else {
          await refreshMatchmakingData();
        }
      },
    );
  }

  Future<void> retryLastOperation() async {
    if (!canRetry) {
      errorMessage.value =
          'Maximum retry attempts reached. Please try again later.';
      return;
    }
    retryCount.value++;
    clearError();
    await _loadMatchmakingData();
  }

  /// --- Core Logic ---

  Future<void> _loadMatchmakingData() async {
    try {
      isLoading.value = true;
      clearError();
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
    } catch (e, stack) {
      _handleError(e, stack, 'matchmaking data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _sendAIMessage(String messageText) async {
    if (!_aiService.isAuthenticated) {
      _addAIMessage('Please log in to use AI Assistant');
      return;
    }

    if (!isSessionValid) await _loadMatchmakingData();

    try {
      isLoading.value = true;
      startAiTyping();
      clearError();
      updateConnectionStatus(true);

      final response = await _aiService.sendChatMessage(
        message: messageText,
        sessionId: sessionId.value.isNotEmpty ? sessionId.value : null,
      );

      if (response['sessionId'] != null) {
        sessionId.value = response['sessionId'];
      }

      updateLastActivity();
      resetRetryCount();

      if (response['response'] != null) {
        _addAIMessage(response['response']);
      }
    } catch (e, stack) {
      _handleError(e, stack, 'AI chat',
          fallbackMessage:
              'Sorry, I\'m having trouble connecting. Please check your internet connection.');
    } finally {
      isLoading.value = false;
      stopAiTyping();
    }
  }

  Future<void> _loadQuickQuestions() async {
    try {
      isQuickQuestionsLoading.value = true;
      quickQuestionsError.value = '';
      updateConnectionStatus(true);

      final questions = await _aiService.getQuickQuestions();
      quickQuestions.value = questions.isNotEmpty
          ? questions
          : [
              'Give me a romantic date idea!',
              "What's my love compatibility?",
            ];

      AppLogger.success('✅ Quick questions loaded successfully');
    } catch (e, stack) {
      quickQuestionsError.value =
          'Failed to load quick questions: ${e.toString()}';
      quickQuestions.value = [
        'Give me a romantic date idea!',
        "What's my love compatibility?",
      ];
      AppLogger.error('Failed to load quick questions', e, stack);
    } finally {
      isQuickQuestionsLoading.value = false;
    }
  }

  /// --- Helpers ---

  void _addUserMessage(String text) => messages.add({
        'text': text,
        'isMe': true,
        'timestamp': DateTime.now(),
      });

  void _addAIMessage(String text, {MatchData? matchData}) => messages.add({
        'text': text,
        'isMe': false,
        'timestamp': DateTime.now(),
        'matchData': matchData,
      });

  Future<void> _handleUserAction({
    required String userMessage,
    required Future<Map<String, dynamic>> Function() apiCall,
    required String defaultResponse,
    required String errorContext,
    Function(Map<String, dynamic>)? onSuccess,
  }) async {
    try {
      startAiTyping();
      clearError();
      updateConnectionStatus(true);

      _addUserMessage(userMessage);

      final response = await apiCall();

      if (response['data'] != null) {
        final msg = response['data']['message'] ?? response['data'];
        _addAIMessage(msg.toString());
      } else if (response['message'] != null) {
        _addAIMessage(response['message']);
      } else {
        _addAIMessage(defaultResponse);
      }

      updateLastActivity();
      resetRetryCount();

      if (onSuccess != null) await onSuccess(response);

      AppLogger.success('✅ $errorContext processed successfully');
    } catch (e, stack) {
      _handleError(e, stack, errorContext,
          fallbackMessage:
              'Sorry, I encountered an error while processing your $errorContext. Please try again.');
    } finally {
      stopAiTyping();
    }
  }

  void _handleError(Object e, StackTrace stack, String context,
      {String? fallbackMessage}) {
    if (e is DioException &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout)) {
      updateConnectionStatus(false);
      errorMessage.value = 'Network error: ${e.message ?? 'Connection failed'}';
    } else {
      errorMessage.value = 'Failed to load $context: ${e.toString()}';
    }

    if (fallbackMessage != null) {
      _addAIMessage(fallbackMessage);
    }

    AppLogger.error('Error in $context', e, stack);
  }

  /// --- Utilities ---

  String formatTime(DateTime ts) =>
      '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}';

  void updateConnectionStatus(bool connected) {
    isConnected.value = connected;
    if (!connected) {
      errorMessage.value = 'No internet connection. Please check your network.';
    }
  }

  void resetRetryCount() => retryCount.value = 0;

  bool get isSessionValid =>
      sessionId.value.isNotEmpty &&
      DateTime.now().difference(lastActivity.value).inMinutes < 30;

  void updateLastActivity() => lastActivity.value = DateTime.now();

  void startAiTyping() => isAiTyping.value = true;
  void stopAiTyping() => isAiTyping.value = false;

  String get connectionStatusMessage {
    if (!isConnected.value) return 'Offline';
    if (isLoading.value) return 'Loading...';
    if (isAiTyping.value) return 'AI is typing...';
    return 'Online';
  }

  Color get statusColor {
    if (!isConnected.value) return Colors.red;
    if (isLoading.value || isAiTyping.value) return Colors.orange;
    return Colors.green;
  }

  // --- Matchmaking Getters ---

  bool get hasCurrentMatch => matchmakingData.value?.data?.currentMatch != null;
  CurrentMatch? get currentMatch => matchmakingData.value?.data?.currentMatch;
  List<String> get commonInterests => currentMatch?.commonInterests ?? [];
  int get matchScore => currentMatch?.matchScore ?? 0;
  List<String> get matchReasons => currentMatch?.reasons ?? [];
  int get matchDistance => currentMatch?.distance.toInt() ?? 0;
  MatchUser? get matchUser => currentMatch?.user;
  bool get hasMoreMatches => matchmakingData.value?.data?.hasMoreMatches ?? false;
  bool get canRetry => retryCount.value < maxRetryAttempts;
  String get retryMessage =>
      'Retry attempt ${retryCount.value + 1} of $maxRetryAttempts';
}
