import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import '../services/ai_assistent_service.dart';
import '../models/ai_assistent_get_model.dart';
import '../../../config/app_routes.dart';
import '../../../modules/profile_and_settings/model/display_profile.dart' as profile_models;

class AiAssistentController extends GetxController {
  // UI controllers
  final TextEditingController messageController = TextEditingController();

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

  // Quick questions (static)
  final RxList<String> quickQuestions = <String>[
    'Give me a romantic date idea!',
    "What's my love compatibility?",
    'How can I improve my relationship?',
    'What are good conversation starters?',
  ].obs;
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
  }

  @override
  void onClose() {
    // Don't dispose messageController here as it might be reused
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
  Future<void> refreshQuickQuestions() async {
    // Since questions are static, just clear any error and reset
    quickQuestionsError.value = '';
    quickQuestions.refresh();
  }

  void clearError() => errorMessage.value = '';
  void clearQuickQuestionsError() => quickQuestionsError.value = '';

  Future<void> processQuickQuestion(String question) async {
    await _handleUserAction(
      userMessage: question,
      apiCall: () async {
        // Just return a simple response, no API call needed
        return {'response': 'Processing your question about: $question'};
      },
      defaultResponse: 'Quick question processed successfully!',
      errorContext: 'quick question',
    );
  }

  /// Convert home CurrentMatch to profile CurrentMatch using direct mapping
  profile_models.CurrentMatch _convertToProfileCurrentMatch(CurrentMatch currentMatch) {
    try {
      // Convert user first
      final profileUser = _convertToProfileMatchUser(currentMatch.user);
      
      // Create profile CurrentMatch
      return profile_models.CurrentMatch(
        user: profileUser,
        matchScore: currentMatch.matchScore,
        commonInterests: List<String>.from(currentMatch.commonInterests),
        reasons: List<String>.from(currentMatch.reasons),
        distance: currentMatch.distance,
      );
    } catch (e) {
      AppLogger.error('❌ [AI ASSISTANT] Error converting CurrentMatch: $e');
      rethrow;
    }
  }
  
  /// Convert home MatchUser to profile MatchUser using direct mapping
  profile_models.MatchUser _convertToProfileMatchUser(MatchUser user) {
    try {
      return profile_models.MatchUser(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        email: user.email,
        phone: user.phone ?? '',
        age: user.age,
        gender: user.gender,
        location: _convertToProfileLocation(user.location),
        bodyImage: user.bodyImage,
        headShotImage: user.headShotImage,
        personalityImage: user.personalityImage,
        image: List<String>.from(user.image),
        likeToMeet: List<String>.from(user.likeToMeet),
        relationType: user.relationType ?? '',
        body: _convertToProfileBody(user.body),
        eduJob: _convertToProfileEduJob(user.eduJob),
        interests: _convertToProfileInterests(user.interests),
        personalTraitsInspire: List<String>.from(user.personalTraitsInspire),
        religion: user.religion,
        zodiacSign: user.zodiacSign,
        lifestyle: _convertToProfileLifestyle(user.lifestyle),
        habits: _convertToProfileHabits(user.habits),
        beliefsOtherText: user.beliefsOtherText ?? '',
        address: user.address,
        traitsOtherText: user.traitsOtherText ?? '',
        aboutMe: user.aboutMe ?? '',
        status: user.status,
        isVerified: user.isVerified,
        profileCompletionPercentage: user.profileCompletionPercentage,
        isDeleted: user.isDeleted,
        updatedAt: '', // Field not available in home model
      );
    } catch (e) {
      AppLogger.error('❌ [AI ASSISTANT] Error converting MatchUser: $e');
      rethrow;
    }
  }
  
  /// Convert home Location to profile Location
  profile_models.Location _convertToProfileLocation(Location? location) {
    if (location == null) {
      return profile_models.Location(type: '', coordinates: []);
    }
    return profile_models.Location(
      type: location.type,
      coordinates: List<double>.from(location.coordinates),
    );
  }
  
  /// Convert home Body to profile Body
  profile_models.Body _convertToProfileBody(Body? body) {
    if (body == null) {
      return profile_models.Body(heightCm: 0, weightKg: 0);
    }
    return profile_models.Body(
      heightCm: body.heightCm,
      weightKg: body.weightKg,
    );
  }
  
  /// Convert home EduJob to profile EduJob
  profile_models.EduJob _convertToProfileEduJob(EduJob? eduJob) {
    if (eduJob == null) {
      return profile_models.EduJob(
        educationLevel: '',
        jobTitle: '',
        annualIncome: 0,
      );
    }
    return profile_models.EduJob(
      educationLevel: eduJob.educationLevel,
      jobTitle: eduJob.jobTitle,
      annualIncome: eduJob.annualIncome,
    );
  }
  
  /// Convert home Interests to profile Interests
  profile_models.Interests _convertToProfileInterests(Interests interests) {
    return profile_models.Interests(
      hobbies: List<String>.from(interests.hobbies),
      creativeOutlets: List<String>.from(interests.creativeOutlets),
      fitnessAndSports: List<String>.from(interests.fitnessAndSports),
      entertainment: List<String>.from(interests.entertainment),
      leisureActivities: List<String>.from(interests.leisureActivities),
      musicGenres: List<String>.from(interests.musicGenres),
      healthAndWellness: List<String>.from(interests.healthAndWellness),
      readingAndContent: List<String>.from(interests.readingAndContent),
    );
  }
  
  /// Convert home Lifestyle to profile Lifestyle
  profile_models.Lifestyle _convertToProfileLifestyle(Lifestyle lifestyle) {
    return profile_models.Lifestyle(
      sleepingStyle: lifestyle.sleepingStyle,
      loveStyle: lifestyle.loveStyle,
      weekends: lifestyle.weekends,
      traveling: lifestyle.traveling,
      homeEnvironment: lifestyle.homeEnvironment,
      livingSpace: lifestyle.livingSpace,
    );
  }
  
  /// Convert home Habits to profile Habits
  profile_models.Habits _convertToProfileHabits(Habits habits) {
    return profile_models.Habits(
      communicationStyle: List<String>.from(habits.communicationStyle),
      workout: habits.workout,
      eatingStyle: List<String>.from(habits.eatingStyle),
      socialMedia: habits.socialMedia,
      smokeOrDrink: habits.smokeOrDrink,
      newExercise: habits.newExercise,
    );
  }
  
  Future<void> discoverMatch() async {
    // Check if we have current match data
    if (matchmakingData.value?.data?.currentMatch != null) {
      final currentMatch = matchmakingData.value!.data!.currentMatch;
      
      // Convert to profile model type
      final profileCurrentMatch = _convertToProfileCurrentMatch(currentMatch);
      
      // Navigate to display profile view with match data
      Get.toNamed(
        AppRoutes.displayProfile,
        arguments: {
          'currentMatch': profileCurrentMatch,
          'user': profileCurrentMatch.user,
        },
      );
    } else {
      // Fallback to original behavior if no match data
      await _handleUserAction(
        userMessage: 'I want to discover more about this match!',
        apiCall: () => _aiService.processDiscoverAction(),
        defaultResponse:
            'Great! Here are more details about your match. Let me know what you think!',
        errorContext: 'discover action',
      );
    }
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

      final response = await _aiService.chatWithAI(
        message: messageText,
        sessionId: sessionId.value.isNotEmpty ? sessionId.value : null,
      );

      // Note: sessionId handling may need to be adjusted based on API response
      // The current model doesn't include sessionId in the response

      updateLastActivity();
      resetRetryCount();

      _addAIMessage(response.data.aiResponse.message);
      
      // If there's match data, add it as a separate message
      if (response.data.currentMatch.user.firstName.isNotEmpty) {
        final matchUser = response.data.currentMatch.user;
        _addAIMessage(
          'I found a match for you! ${matchUser.firstName} ${matchUser.lastName}, ${matchUser.age}',
          matchData: MatchData(
            userImage: [matchUser.headShotImage, ...matchUser.image],
            commonInterests: response.data.currentMatch.commonInterests,
            userId: matchUser.id,
            userFirstName: matchUser.firstName,
            userLastName: matchUser.lastName,
            userGender: matchUser.gender,
            userAge: matchUser.age,
            matchScore: response.data.currentMatch.matchScore,
            distance: response.data.currentMatch.distance.toDouble(),
          ),
        );
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
        String msg;
        if (response['data'] is Map<String, dynamic>) {
          msg = response['data']['message']?.toString() ?? response['data'].toString();
        } else {
          msg = response['data'].toString();
        }
        _addAIMessage(msg);
      } else if (response['message'] != null) {
        _addAIMessage(response['message'].toString());
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
