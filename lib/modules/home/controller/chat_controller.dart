import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/logger/app_logger.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:kindered_app/local/storage_keys.dart';
import '../services/create_chat_service.dart';
import '../services/send_message_service.dart';
import '../services/get_message.dart';
import '../models/create_chat.dart';
import '../models/send_message_model.dart';
import '../models/get_message_model.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  final CreateChatService _createChatService = CreateChatService(Dio());
  final SendMessageService _sendMessageService = SendMessageService();
  final GetMessageService _getMessageService = GetMessageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Reactive variables
  final Rx<CreateChatResponse?> chatResponse = Rx<CreateChatResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString participantName = ''.obs;
  final RxString participantId = ''.obs;
  final RxString currentUserId = ''.obs;
  
  // Messages lists
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<Message> chatMessages = <Message>[].obs;
  
  // Message sending reactive variables
  final RxString messageSendingError = ''.obs;
  final RxBool isImageUploading = false.obs;
  final RxString imageUploadError = ''.obs;
  
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
      
      AppLogger.info('💬 CHAT CONTROLLER INITIALIZATION STARTED ===');
      AppLogger.info('📦 Navigation Arguments Received: $arguments');
      
      // Ensure LocalStorage data is loaded
      if (LocalStorage.userId.isEmpty) {
        AppLogger.warning('⚠️ LocalStorage.userId is empty, attempting to reload...');
        LocalStorage.getAllPrefData();
      }
      
      if (arguments != null) {
        // Extract all arguments
        final chatId = arguments['chatId'] ?? '';
        participantName.value = arguments['participantName'] ?? '';
        participantId.value = arguments['participantId'] ?? '';
        
        // Get current user ID with fallbacks
        String currentUserIdValue = arguments['currentUserId'] ?? LocalStorage.userId;
        if (currentUserIdValue.isEmpty) {
          AppLogger.warning('⚠️ currentUserId is empty from both arguments and LocalStorage');
          // Try to get from SharedPreferences directly as last resort
          currentUserIdValue = LocalStorage.preferences?.getString(LocalStorageKeys.userId) ?? '';
          AppLogger.info('🔍 Retrieved currentUserId from SharedPreferences: $currentUserIdValue');
        }
        currentUserId.value = currentUserIdValue;
        
        final suggestedUserId = arguments['suggestedUserId'] ?? '';
        
        AppLogger.info('🎯 CHAT CONTROLLER - ARGUMENTS PARSED ===');
        AppLogger.info('📋 All Arguments:');
        AppLogger.info('  - chatId: $chatId');
        AppLogger.info('  - participantName: ${participantName.value}');
        AppLogger.info('  - participantId: ${participantId.value}');
        AppLogger.info('  - currentUserId: ${currentUserId.value}');
        AppLogger.info('  - suggestedUserId: $suggestedUserId');
        AppLogger.info('👥 User Information:');
        AppLogger.info('  - Current User: ${currentUserId.value}');
        AppLogger.info('  - Participant: ${participantName.value} (${participantId.value})');
        AppLogger.info('🆔 Chat ID Tracking:');
        AppLogger.info('  - Received Chat ID: $chatId');
        AppLogger.info('  - Chat ID is not empty: ${chatId.isNotEmpty}');
        AppLogger.info('  - Will Create New Chat: ${participantId.value.isNotEmpty && currentUserId.value.isNotEmpty && chatId.isEmpty}');
        
        // Debug: Check LocalStorage state
        AppLogger.info('🔍 LocalStorage State Debug:');
        AppLogger.info('  - LocalStorage.userId: ${LocalStorage.userId}');
        AppLogger.info('  - LocalStorage.token: ${LocalStorage.token.isNotEmpty ? "[PRESENT]" : "[EMPTY]"}');
        AppLogger.info('  - LocalStorage.isLogIn: ${LocalStorage.isLogIn}');
        
        // If we have a valid chat ID from the message list, create a mock chat response
        if (chatId.isNotEmpty) {
          AppLogger.info('🎯 Using existing chat ID from message list: $chatId');
          
          // Create a mock chat response for existing chat
          final mockChatData = ChatData(
            id: chatId,
            participants: [
              currentUserId.value,
              participantId.value,
            ].where((id) => id.isNotEmpty).toList(),
            lastMessage: null, // No last message for mock
            status: 'active',
            isDeleted: false,
            readBy: [],
            mutedBy: [],
            deletedByDetails: [],
            blockedUsers: [],
            userPinnedMessages: [],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            v: 0,
          );
          
          final mockChatResponse = CreateChatResponse(
            success: true,
            message: 'Existing chat loaded',
            statusCode: 200,
            data: mockChatData,
          );
          
          chatResponse.value = mockChatResponse;
          AppLogger.info('✅ Existing chat loaded successfully');
          AppLogger.info('  - Chat ID: ${chatResponse.value?.data.id}');
          AppLogger.info('  - Participants: ${chatResponse.value?.data.participants}');
          
          // Fetch messages for the existing chat
          fetchMessages();
          
        } else if (participantId.value.isNotEmpty) {
          // If we have participant ID but no chat ID, create new chat
          AppLogger.info('🚀 Creating new chat with participant: ${participantId.value}');
          _createChatWithParticipant();
        } else {
          AppLogger.warning('⚠️ Cannot create chat - missing participant ID');
          AppLogger.warning('   - participantId: "${participantId.value}" (empty: ${participantId.value.isEmpty})');
          errorMessage.value = 'Missing participant information';
        }
      } else {
        AppLogger.warning('⚠️ No navigation arguments received in chat controller');
        errorMessage.value = 'No chat information provided';
      }
      
      AppLogger.info('=== CHAT CONTROLLER INITIALIZATION COMPLETED ===');
    } catch (e) {
      AppLogger.error('❌ Error initializing chat controller: $e');
      errorMessage.value = 'Failed to initialize chat';
    }
  }
  
  /// Create chat with the participant
  Future<void> _createChatWithParticipant() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    AppLogger.info('🔨 CHAT CREATION PROCESS STARTED ===');
    AppLogger.info('👥 Chat Participants:$participantId.value');
    AppLogger.info('  - Participant Name: ${participantName.value}');
    
    try {
      AppLogger.info('📡 Calling CreateChatService...');
      
      // Get current user ID from LocalStorage for logging
      final currentUserId = LocalStorage.userId;
      AppLogger.info('📡 Current User ID from LocalStorage: "$currentUserId"');
      
      // Debug: Check all LocalStorage authentication data
      AppLogger.info('🔍 LOCAL STORAGE DEBUG ===');
      AppLogger.info('  - token: ${LocalStorage.token.isNotEmpty ? "[PRESENT] (${LocalStorage.token.length} chars)" : "[EMPTY]"}');
      AppLogger.info('  - isLogIn: ${LocalStorage.isLogIn}');
      AppLogger.info('  - userId: "${LocalStorage.userId}"');
      AppLogger.info('  - myName: "${LocalStorage.myName}"');
      AppLogger.info('  - myEmail: "${LocalStorage.myEmail}"');
      AppLogger.info('  - myImage: "${LocalStorage.myImage}"');
      AppLogger.info('  - phone: "${LocalStorage.phone}"');
      AppLogger.info('🔍 END LOCAL STORAGE DEBUG ===');
      
      // Send only the suggested user's ID (from home suggestion photo card)
      if (participantId.value.isNotEmpty && participantId.value != 'null') {
        AppLogger.info('📡 Sending only suggested user ID: ${participantId.value}');
      } else {
        // If no valid participant ID, show error and don't proceed
        AppLogger.error('❌ Suggested user ID is empty or invalid: "${participantId.value}"');
        Get.snackbar(
          'Chat Error',
          'No valid participant found for chat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return; // Stop the chat creation process
      }
      
      AppLogger.info('📡 Final participant: ${participantId.value}');
      
      final response = await _createChatService.createChat(
        participant: participantId.value,
      );
      
      chatResponse.value = response;
      
      AppLogger.info('✅ CHAT CREATED SUCCESSFULLY ===');
      AppLogger.info('🆔 Chat Details:');
      AppLogger.info('  - Chat ID: ${response.data.id}');
      AppLogger.info('  - Participants: ${response.data.participants}');
      AppLogger.info('  - Status: ${response.data.status}');
      AppLogger.info('  - Created At: ${response.data.createdAt}');
      AppLogger.info('  - Updated At: ${response.data.updatedAt}');
      
      // Fetch messages for the newly created chat
      await fetchMessages();
      
      // Additional logging for debugging
      if (response.data.participants.isNotEmpty) {
        AppLogger.info('👥 Participant List:');
        for (int i = 0; i < response.data.participants.length; i++) {
          AppLogger.info('  - Participant ${i + 1}: ${response.data.participants[i]}');
        }
      }
      
    } catch (e) {
      AppLogger.error('❌ ERROR CREATING CHAT ===');
      AppLogger.error('Error details: $e');
      AppLogger.error('Error type: ${e.runtimeType}');
      errorMessage.value = 'Failed to create chat: $e';
    } finally {
      isLoading.value = false;
      AppLogger.info('🏁 CHAT CREATION PROCESS COMPLETED ===');
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

  /// Fetch messages for the current chat
  Future<void> fetchMessages() async {
    if (!hasChat || isLoadingMessages.value) return;
    
    isLoadingMessages.value = true;
    
    try {
      AppLogger.info('[CHAT CONTROLLER] Fetching messages for chat: ${chatId}');
      
      final response = await _getMessageService.getMessages(
        chatId: chatId,
        page: 1,
        limit: 50,
      );
      
      if (response.success) {
        chatMessages.clear();
        chatMessages.addAll(response.data.messages);
        
        AppLogger.info('[CHAT CONTROLLER] Messages fetched successfully');
        AppLogger.info('[CHAT CONTROLLER] Total messages: ${chatMessages.length}');
        
        // Also update the old messages list for backward compatibility
        messages.clear();
        for (final message in chatMessages) {
          final isSentByMe = message.sender.id == currentUserId.value;
          messages.add({
            'id': message.id,
            'text': message.text,
            'type': message.type,
            'sender': message.sender.toJson(),
            'createdAt': message.createdAt,
            'isSentByMe': isSentByMe,
            'images': message.images,
          });
        }
      } else {
        AppLogger.error('[CHAT CONTROLLER] Failed to fetch messages: ${response.message}');
        Get.snackbar(
          'Error',
          'Failed to load messages: ${response.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      AppLogger.error('[CHAT CONTROLLER] Error fetching messages: $e');
      Get.snackbar(
        'Error',
        'Failed to load messages: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Send a text message
  Future<void> sendTextMessage(String content) async {
    print('🚀 [CHAT CONTROLLER] sendTextMessage called');
    print('📝 [CHAT CONTROLLER] Content: "$content"');
    print('💬 [CHAT CONTROLLER] hasChat: $hasChat');
    print('🆔 [CHAT CONTROLLER] chatId: "$chatId"');
    print('🔄 [CHAT CONTROLLER] isSendingMessage: $isSendingMessage');
    
    if (!hasChat || content.trim().isEmpty) {
      print('⚠️ [CHAT CONTROLLER] Cannot send - no chat or empty content');
      print('   - hasChat: $hasChat');
      print('   - content.isEmpty: ${content.trim().isEmpty}');
      AppLogger.warning('[CHAT CONTROLLER] Cannot send message - no chat or empty content');
      return;
    }

    if (isSendingMessage.value) {
      print('⚠️ [CHAT CONTROLLER] Already sending a message');
      AppLogger.warning('[CHAT CONTROLLER] Already sending a message');
      return;
    }

    print('✅ [CHAT CONTROLLER] Starting to send message...');
    isSendingMessage.value = true;
    messageSendingError.value = '';

    try {
      AppLogger.info('[CHAT CONTROLLER] Sending text message to chat: $chatId');
      AppLogger.info('[CHAT CONTROLLER] Message content: $content');

      print('📡 [CHAT CONTROLLER] Calling SendMessageService...');
      final SendMessageResponse response = await _sendMessageService.sendTextMessage(
        chatId: chatId,
        content: content.trim(),
      );
      print('✅ [CHAT CONTROLLER] SendMessageService returned successfully');

      AppLogger.info('[CHAT CONTROLLER] Message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('[CHAT CONTROLLER] Message created at: ${response.data.createdAt}');

      print('🎉 [CHAT CONTROLLER] Message sent successfully!');
      print('   - Success: ${response.success}');
      print('   - Message: ${response.message}');
      print('   - Message ID: ${response.data.id}');
      print('   - Message Type: ${response.data.type}');

      // Add the sent message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      AppLogger.info('[CHAT CONTROLLER] Message added to local list');
      AppLogger.info('[CHAT CONTROLLER] Total messages: ${messages.length}');

    } catch (e) {
      print('❌ [CHAT CONTROLLER] Error sending message: $e');
      print('   - Error type: ${e.runtimeType}');
      AppLogger.error('[CHAT CONTROLLER] Error sending message: $e');
      messageSendingError.value = e.toString();
      
      // Show error feedback
      Get.snackbar(
        'Send Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      print('🏁 [CHAT CONTROLLER] Finally block - resetting isSendingMessage');
      isSendingMessage.value = false;
    }
  }

  /// Send a mixed message (text + image)
  Future<void> sendMixedMessage({
    required String text,
    required String imageUrl,
    String messageType = 'both',
  }) async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send mixed message - no chat');
      return;
    }

    if (isSendingMessage.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already sending a message');
      return;
    }

    isSendingMessage.value = true;
    messageSendingError.value = '';

    try {
      AppLogger.info('[CHAT CONTROLLER] Sending mixed message to chat: $chatId');
      AppLogger.info('[CHAT CONTROLLER] Text: $text');
      AppLogger.info('[CHAT CONTROLLER] Image URL: $imageUrl');
      AppLogger.info('[CHAT CONTROLLER] Message type: $messageType');

      final SendMessageResponse response = await _sendMessageService.sendMixedMessage(
        chatId: chatId,
        text: text,
        imageUrl: imageUrl,
        messageType: messageType,
      );

      AppLogger.info('[CHAT CONTROLLER] Mixed message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');

      // Add the sent message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      AppLogger.info('[CHAT CONTROLLER] Mixed message added to local list');
      AppLogger.info('[CHAT CONTROLLER] Total messages: ${messages.length}');

    } catch (e) {
      AppLogger.error('[CHAT CONTROLLER] Error sending mixed message: $e');
      messageSendingError.value = e.toString();
      
      Get.snackbar(
        'Send Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Send a custom message type
  Future<void> sendCustomMessage({
    required String content,
    required String messageType,
    List<String>? images,
  }) async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send custom message - no chat');
      return;
    }

    if (isSendingMessage.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already sending a message');
      return;
    }

    isSendingMessage.value = true;
    messageSendingError.value = '';

    try {
      AppLogger.info('[CHAT CONTROLLER] Sending custom message to chat: $chatId');
      AppLogger.info('[CHAT CONTROLLER] Content: $content');
      AppLogger.info('[CHAT CONTROLLER] Message type: $messageType');
      if (images != null) {
        AppLogger.info('[CHAT CONTROLLER] Images: $images');
      }

      final SendMessageResponse response = await _sendMessageService.sendCustomMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
        images: images,
      );

      AppLogger.info('[CHAT CONTROLLER] Custom message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');

      // Add the sent message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      AppLogger.info('[CHAT CONTROLLER] Custom message added to local list');
      AppLogger.info('[CHAT CONTROLLER] Total messages: ${messages.length}');

    } catch (e) {
      AppLogger.error('[CHAT CONTROLLER] Error sending custom message: $e');
      messageSendingError.value = e.toString();
      
      Get.snackbar(
        'Send Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Pick and send an image message
  Future<void> pickAndSendImage() async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send image - no chat');
      return;
    }

    if (isImageUploading.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already uploading an image');
      return;
    }

    try {
      AppLogger.info('[CHAT CONTROLLER] Opening image picker');
      
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        AppLogger.info('[CHAT CONTROLLER] User cancelled image selection');
        return;
      }

      isImageUploading.value = true;
      imageUploadError.value = '';

      AppLogger.info('[CHAT CONTROLLER] Image selected: ${imageFile.path}');
      AppLogger.info('[CHAT CONTROLLER] Image size: ${imageFile.length} bytes');

      // For now, we'll use a placeholder URL since we don't have image upload functionality
      // In a real app, you would upload the image to a server and get the URL
      final imageUrl = 'file://${imageFile.path}';
      
      AppLogger.info('[CHAT CONTROLLER] Sending image message to chat: $chatId');

      final SendMessageResponse response = await _sendMessageService.sendImageMessage(
        chatId: chatId,
        imageUrl: imageUrl,
        caption: '', // You can add caption functionality later
      );

      AppLogger.info('[CHAT CONTROLLER] Image message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('[CHAT CONTROLLER] Message text: ${response.data.text}');
      AppLogger.info('[CHAT CONTROLLER] Message created at: ${response.data.createdAt}');

      // Add the sent image message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      AppLogger.info('[CHAT CONTROLLER] Image message added to local list');
      AppLogger.info('[CHAT CONTROLLER] Total messages: ${messages.length}');

    } catch (e) {
      AppLogger.error('[CHAT CONTROLLER] Error sending image: $e');
      imageUploadError.value = e.toString();
      
      // Show error feedback
      Get.snackbar(
        'Image Send Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  /// Take a photo and send it as a message
  Future<void> takeAndSendPhoto() async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send photo - no chat');
      return;
    }

    if (isImageUploading.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already uploading an image');
      return;
    }

    try {
      AppLogger.info('[CHAT CONTROLLER] Opening camera');
      
      final XFile? photoFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photoFile == null) {
        AppLogger.info('[CHAT CONTROLLER] User cancelled photo capture');
        return;
      }

      isImageUploading.value = true;
      imageUploadError.value = '';

      AppLogger.info('[CHAT CONTROLLER] Photo captured: ${photoFile.path}');
      AppLogger.info('[CHAT CONTROLLER] Photo size: ${photoFile.length} bytes');

      // For now, we'll use a placeholder URL since we don't have image upload functionality
      // In a real app, you would upload the image to a server and get the URL
      final photoUrl = 'file://${photoFile.path}';
      
      AppLogger.info('[CHAT CONTROLLER] Sending photo message to chat: $chatId');

      final SendMessageResponse response = await _sendMessageService.sendImageMessage(
        chatId: chatId,
        imageUrl: photoUrl,
        caption: '', // You can add caption functionality later
      );

      AppLogger.info('[CHAT CONTROLLER] Photo message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('[CHAT CONTROLLER] Message text: ${response.data.text}');
      AppLogger.info('[CHAT CONTROLLER] Message created at: ${response.data.createdAt}');

      // Add the sent photo message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      AppLogger.info('[CHAT CONTROLLER] Photo message added to local list');
      AppLogger.info('[CHAT CONTROLLER] Total messages: ${messages.length}');

    } catch (e) {
      AppLogger.error('[CHAT CONTROLLER] Error sending photo: $e');
      imageUploadError.value = e.toString();
      
      // Show error feedback
      Get.snackbar(
        'Photo Send Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isImageUploading.value = false;
    }
  }

  /// Clear message sending error
  void clearMessageSendingError() {
    messageSendingError.value = '';
  }

  /// Clear image upload error
  void clearImageUploadError() {
    imageUploadError.value = '';
  }
}
