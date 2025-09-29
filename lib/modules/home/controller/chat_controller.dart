import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:kindered_app/core/app_urls.dart';
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
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatController extends GetxController {
  final CreateChatService _createChatService = CreateChatService(Dio());
  final SendMessageService _sendMessageService = SendMessageService();
  final GetMessageService _getMessageService = GetMessageService();
  final ImagePicker _imagePicker = ImagePicker();
  
  // Socket.io instance
  IO.Socket? socket;
  
  // Reactive variables
  final Rx<CreateChatResponse?> chatResponse = Rx<CreateChatResponse?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isSendingMessage = false.obs;
  final RxBool isLoadingMessages = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString participantName = ''.obs;
  final RxString participantId = ''.obs;
  final RxString currentUserId = ''.obs;
  
  // WebSocket connection status
  final RxBool isConnected = false.obs;
  final RxString connectionStatus = 'Disconnected'.obs;
  
  // Typing indicators
  final RxBool isParticipantTyping = false.obs;
  final RxString typingStatus = ''.obs;
  
  // Messages lists
  final RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final RxList<Message> chatMessages = <Message>[].obs;
  
  // Message sending reactive variables
  final RxString messageSendingError = ''.obs;
  final RxBool isImageUploading = false.obs;
  final RxString imageUploadError = ''.obs;
  
  // Pending message data (for UI preview)
  final RxString draftMessage = ''.obs;
  final RxList<String> pendingImages = <String>[].obs;
  final RxBool hasPendingContent = false.obs;
  
  // Getters
  bool get hasChat => chatResponse.value != null;
  String get chatId => chatResponse.value?.data.id ?? '';
  List<String> get participants => chatResponse.value?.data.participants ?? [];
  bool get hasPendingMessage => draftMessage.value.isNotEmpty || pendingImages.isNotEmpty;
  
  @override
  void onInit() {
    super.onInit();
    _initializeFromArguments();
    _initializeSocket();
  }
  
  @override
  void onClose() {
    _disconnectSocket();
    super.onClose();
  }
  
  /// Initialize controller data from navigation arguments
  void _initializeFromArguments() {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;
      
      
      // Ensure LocalStorage data is loaded
      if (LocalStorage.userId.isEmpty) {
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
          // Try to get from SharedPreferences directly as last resort
          currentUserIdValue = LocalStorage.preferences?.getString(LocalStorageKeys.userId) ?? '';
        }
        currentUserId.value = currentUserIdValue;
        
        
        
        // Debug: Check LocalStorage state
        
        // If we have a valid chat ID from the message list, create a mock chat response
        if (chatId.isNotEmpty) {
          
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
          
          // Fetch messages for the existing chat
          fetchMessages();
          
        } else if (participantId.value.isNotEmpty) {
          // If we have participant ID but no chat ID, create new chat
          _createChatWithParticipant();
        } else {
        }
      } else {
        errorMessage.value = 'No chat information provided';
      }
      
    } catch (e) {
      _handleApiError('onInit', e);
    }
  }
  
  /// Create chat with the participant
  Future<void> _createChatWithParticipant() async {
    if (isLoading.value) return;
    
    isLoading.value = true;
    errorMessage.value = '';
    
    
    try {
      
      
      // Debug: Check all LocalStorage authentication data
      
      // Send only the suggested user's ID (from home suggestion photo card)
      if (participantId.value.isNotEmpty && participantId.value != 'null') {
      } else {
        // If no valid participant ID, show error and don't proceed
        _showErrorSnackbar('Chat Error', 'No valid participant found for chat');
        return; // Stop the chat creation process
      }
      
      
      final response = await _createChatService.createChat(
        participant: participantId.value,
      );
      
      chatResponse.value = response;
      
      
      // Fetch messages for the newly created chat
      // Note: For new chats, this might return 400 error which is normal
      try {
        await fetchMessages();
      } catch (e) {
        // For new chats, it's normal to have no messages yet
        // Clear any error messages and show empty chat
        messages.clear();
        chatMessages.clear();
      }
      
      // Join the chat room via WebSocket after successful chat creation
      if (isConnected.value) {
        _joinChatRoom();
      } else {
      }
      
      // Additional logging for debugging
      if (response.data.participants.isNotEmpty) {
      }
      
    } catch (e) {
      _handleApiError('createChatWithParticipant', e);
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
        
        // Force UI update
        chatMessages.refresh();
        
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
        AppLogger.warning('[CHAT CONTROLLER] Could not fetch messages: ${response.message}');
        // For new chats or empty chats, this is normal
        // Clear messages and show empty chat
        messages.clear();
        chatMessages.clear();
        
        // Force UI update
        chatMessages.refresh();
      }
    } catch (e) {
      _handleApiError('fetchMessages', e);
      // For new chats, it's normal to have no messages yet
      // Clear any error messages and show empty chat
      messages.clear();
      chatMessages.clear();
      
      // Force UI update
      chatMessages.refresh();
      
      // Only show error snackbar if it's not a 400 error (which is normal for new chats)
      if (!e.toString().contains('400') && !e.toString().contains('Client error')) {
        _showErrorSnackbar('Chat Info', 'Starting new conversation...');
      }
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// Update draft message
  void updateDraftMessage(String text) {
    draftMessage.value = text;
    _updateHasPendingContent();
  }

  /// Add pending image
  void addPendingImage(String imagePath) {
    pendingImages.add(imagePath);
    _updateHasPendingContent();
  }

  /// Remove pending image
  void removePendingImage(String imagePath) {
    pendingImages.remove(imagePath);
    _updateHasPendingContent();
  }

  /// Clear all pending content
  void clearPendingContent() {
    draftMessage.value = '';
    pendingImages.clear();
    _updateHasPendingContent();
  }

  /// Update hasPendingContent flag
  void _updateHasPendingContent() {
    hasPendingContent.value = hasPendingMessage;
  }

  /// Send image from file path
  Future<void> sendImageFromPath(String imagePath) async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send image - no chat');
      return;
    }

    if (isImageUploading.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already uploading an image');
      return;
    }

    try {
      isImageUploading.value = true;
      imageUploadError.value = '';
      // Create File object from the image path
      final imageFile = File(imagePath);
      
      // Enhanced logging for image sending
      AppLogger.info('🚀 [CHAT CONTROLLER] SENDING IMAGE (Direct Form-Data)');
      AppLogger.info('📁 [CHAT CONTROLLER] Original image path: $imagePath');
      AppLogger.info('💬 [CHAT CONTROLLER] Chat ID: $chatId');

      AppLogger.info('📤 [CHAT CONTROLLER] Sending image with form-data...');
      final SendMessageResponse response = await _sendMessageService.sendMessageWithImage(
        chatId: chatId,
        imageFile: imageFile,
        content: '', // You can add caption functionality later
      );

      AppLogger.info('✅ [CHAT CONTROLLER] Image message sent successfully');
      AppLogger.info('📊 [CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('🆔 [CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('📝 [CHAT CONTROLLER] Message text: ${response.data.text}');
      AppLogger.info('🏷️ [CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('🖼️ [CHAT CONTROLLER] Response images: ${response.data.images}');

      // Add the sent image message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });

      // Also add to chatMessages for reactive UI
      try {
        final senderId = response.data.sender;
        
        // Log the processed image URLs
        final processedImages = _processImageUrls(response.data.images);
        AppLogger.info('🔄 [CHAT CONTROLLER] Processed image URLs: $processedImages');
        
        final imageMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '',
            image: [],
            firstName: '',
            lastName: '',
          ),
          text: response.data.text,
          type: response.data.type,
          images: processedImages,
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        _addMessageToLists(imageMessage, legacyMessage: {
          'id': imageMessage.id,
          'text': imageMessage.text,
          'type': imageMessage.type,
          'sender': imageMessage.sender.toJson(),
          'createdAt': imageMessage.createdAt,
          'isSentByMe': true,
          'images': imageMessage.images,
        });
        
        AppLogger.info('[CHAT CONTROLLER] Image message added to reactive UI');
      } catch (e) {
        _handleApiError('createImageMessageObject', e);
      }

    } catch (e) {
      _handleApiError('sendImageFromPath', e);
    } finally {
      isImageUploading.value = false;
    }
  }


  /// Send pending message (text + images)
  Future<void> sendPendingMessage() async {
    if (!hasPendingMessage) return;
    
    final text = draftMessage.value;
    final images = List<String>.from(pendingImages);
    
    // Clear pending content first
    clearPendingContent();
    
    if (images.isNotEmpty) {
      if (text.isNotEmpty) {
        // Send mixed message (text + images)
        await sendMixedMessage(
          text: text,
          imageUrl: images.first, // For now, send first image
          messageType: 'both',
        );
      } else {
        // Send image only
        await sendImageFromPath(images.first);
      }
    } else if (text.isNotEmpty) {
      // Send text only
      await sendTextMessage(text);
    }
  }

  /// Send a text message
  Future<void> sendTextMessage(String content) async {
    
    if (!hasChat || content.trim().isEmpty) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot send message - no chat or empty content');
      return;
    }

    if (isSendingMessage.value) {
      AppLogger.warning('[CHAT CONTROLLER] Already sending a message');
      return;
    }
    isSendingMessage.value = true;
    messageSendingError.value = '';

    try {
      final SendMessageResponse response = await _sendMessageService.sendTextMessage(
        chatId: chatId,
        content: content.trim(),
      );

      AppLogger.info('[CHAT CONTROLLER] Message sent successfully');
      AppLogger.info('[CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('[CHAT CONTROLLER] Response message: ${response.message}');
      AppLogger.info('[CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('[CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('[CHAT CONTROLLER] Message created at: ${response.data.createdAt}');


      // Add the sent message to the chatMessages list (used by UI)
      try {
        final sentMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: response.data.sender,
            email: '',
            image: [],
            firstName: '',
            lastName: '',
          ),
          text: response.data.text,
          type: response.data.type,
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        _addMessageToLists(sentMessage, legacyMessage: {
          'id': sentMessage.id,
          'text': sentMessage.text,
          'type': sentMessage.type,
          'sender': sentMessage.sender.toJson(),
          'createdAt': sentMessage.createdAt,
          'isSentByMe': true,
          'images': sentMessage.images,
        });
        
        AppLogger.info('[CHAT CONTROLLER] Successfully created and added sent Message object');
      } catch (e) {
        _handleApiError('createSentMessageObject', e);
      }
      
      
      // Emit message via WebSocket for real-time delivery with dynamic user ID
      if (isConnected.value) {
        try {
          final userId = _getCurrentUserId();
          socket?.emit('sendMessage', {
            'chatId': chatId,
            'messageId': response.data.id,
            'sender': userId,
            'text': response.data.text,
            'type': response.data.type,
            'createdAt': response.data.createdAt,
          });
          AppLogger.info('📨 Message emitted via WebSocket for user: $userId');
        } catch (e) {
          _handleApiError('emitMessageWebSocket', e);
        }
      } else {
        AppLogger.warning('⚠️ WebSocket not connected, message not sent via real-time');
      }

    } catch (e) {
      _handleApiError('sendTextMessage', e);
      messageSendingError.value = e.toString();
      
      // Show error feedback
      _showErrorSnackbar('Send Failed', e.toString());
    } finally {
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
      
      // Also add to chatMessages for reactive UI
      try {
        // The sender is a String (sender ID) from the API response
        final senderId = response.data.sender;
        
        final mixedMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '', // API doesn't provide email in response
            image: [], // API doesn't provide image list in response
            firstName: '', // API doesn't provide firstName in response
            lastName: '', // API doesn't provide lastName in response
          ),
          text: response.data.text,
          type: response.data.type,
          images: _processImageUrls(response.data.images), // Add the images from the response
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        
        _addMessageToLists(mixedMessage, legacyMessage: {
          'id': mixedMessage.id,
          'text': mixedMessage.text,
          'type': mixedMessage.type,
          'sender': mixedMessage.sender.toJson(),
          'createdAt': mixedMessage.createdAt,
          'isSentByMe': true,
          'images': mixedMessage.images,
        });
        AppLogger.info('[CHAT CONTROLLER] Mixed message added to reactive UI');
      } catch (e) {
        _handleApiError('createMixedMessageObject', e);
        _showErrorSnackbar('Send Failed', e.toString());
      }

    } catch (e) {
      _handleApiError('sendMixedMessage', e);
      _showErrorSnackbar('Send Failed', e.toString());
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
      
      // Also add to chatMessages for reactive UI
      try {
        // The sender is a String (sender ID) from the API response
        final senderId = response.data.sender;
        
        final customMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '', // API doesn't provide email in response
            image: [], // API doesn't provide image list in response
            firstName: '', // API doesn't provide firstName in response
            lastName: '', // API doesn't provide lastName in response
          ),
          text: response.data.text,
          type: response.data.type,
          images: _processImageUrls(response.data.images), // Add the images from the response
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        
        _addMessageToLists(customMessage, legacyMessage: {
          'id': customMessage.id,
          'text': customMessage.text,
          'type': customMessage.type,
          'sender': customMessage.sender.toJson(),
          'createdAt': customMessage.createdAt,
          'isSentByMe': true,
          'images': customMessage.images,
        });
        
        AppLogger.info('[CHAT CONTROLLER] Custom message added to reactive UI');
      } catch (e) {
        _handleApiError('createCustomMessageObject', e);
      }

    } catch (e) {
      _handleApiError('sendCustomMessage', e);
      messageSendingError.value = e.toString();
      
      _showErrorSnackbar('Send Failed', e.toString());
    } finally {
      isSendingMessage.value = false;
    }
  }

  /// Pick image and add to pending list
  Future<void> pickImageForPreview() async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot pick image - no chat');
      return;
    }

    try {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        return;
      }

      // Add image to pending list for preview
      addPendingImage(imageFile.path);
      AppLogger.info('[CHAT CONTROLLER] Image added to pending list: ${imageFile.path}');
    } catch (e) {
      _handleApiError('pickImageForPreview', e);
    }
  }

  /// Take photo and add to pending list
  Future<void> takePhotoForPreview() async {
    if (!hasChat) {
      AppLogger.warning('[CHAT CONTROLLER] Cannot take photo - no chat');
      return;
    }

    try {
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        return;
      }

      // Add image to pending list for preview
      addPendingImage(imageFile.path);
      AppLogger.info('[CHAT CONTROLLER] Photo added to pending list: ${imageFile.path}');
    } catch (e) {
      _handleApiError('takePhotoForPreview', e);
    }
  }

  /// Pick and send an image message (legacy method)
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
      
      final XFile? imageFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (imageFile == null) {
        return;
      }

      isImageUploading.value = true;
      imageUploadError.value = '';

      // Create File object from the picked file
      final file = File(imageFile.path);
      
      // Enhanced logging for image sending
      AppLogger.info('🚀 [CHAT CONTROLLER] SENDING IMAGE (Direct Form-Data)');
      AppLogger.info('📁 [CHAT CONTROLLER] Original image path: ${imageFile.path}');
      AppLogger.info('💬 [CHAT CONTROLLER] Chat ID: $chatId');

      AppLogger.info('📤 [CHAT CONTROLLER] Sending image with form-data...');
      final SendMessageResponse response = await _sendMessageService.sendMessageWithImage(
        chatId: chatId,
        imageFile: file,
        content: '', // You can add caption functionality later
      );

      AppLogger.info('✅ [CHAT CONTROLLER] Image message sent successfully');
      AppLogger.info('📊 [CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('🆔 [CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('📝 [CHAT CONTROLLER] Message text: ${response.data.text}');
      AppLogger.info('🏷️ [CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('🖼️ [CHAT CONTROLLER] Response images: ${response.data.images}');

      // Add the sent image message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      // Also add to chatMessages for reactive UI
      try {
        // The sender is a String (sender ID) from the API response
        final senderId = response.data.sender;
        
        // Log the processed image URLs
        final processedImages = _processImageUrls(response.data.images);
        AppLogger.info('🔄 [CHAT CONTROLLER] Processed image URLs: $processedImages');
        
        final imageMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '', // API doesn't provide email in response
            image: [], // API doesn't provide image list in response
            firstName: '', // API doesn't provide firstName in response
            lastName: '', // API doesn't provide lastName in response
          ),
          text: response.data.text,
          type: response.data.type,
          images: processedImages,
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        
        _addMessageToLists(imageMessage, legacyMessage: {
          'id': imageMessage.id,
          'text': imageMessage.text,
          'type': imageMessage.type,
          'sender': imageMessage.sender.toJson(),
          'createdAt': imageMessage.createdAt,
          'isSentByMe': true,
          'images': imageMessage.images,
        });
        AppLogger.info('✅ [CHAT CONTROLLER] Image message added to reactive UI');
      } catch (e) {
        _handleApiError('createImageMessageObject', e);
      }
      
    } catch (e) {
      _handleApiError('pickAndSendImage', e);
      _showErrorSnackbar('Image Send Failed', e.toString());
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
      
      final XFile? photoFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photoFile == null) {
        return;
      }

      // Create File object from the photo
      final file = File(photoFile.path);
      
      // Enhanced logging for image sending
      AppLogger.info('🚀 [CHAT CONTROLLER] SENDING IMAGE (Camera Form-Data)');
      AppLogger.info('📁 [CHAT CONTROLLER] Original photo path: ${photoFile.path}');
      AppLogger.info('💬 [CHAT CONTROLLER] Chat ID: $chatId');

      AppLogger.info('📤 [CHAT CONTROLLER] Sending photo with form-data...');
      final SendMessageResponse response = await _sendMessageService.sendMessageWithImage(
        chatId: chatId,
        imageFile: file,
        content: '', // You can add caption functionality later
      );

      AppLogger.info('✅ [CHAT CONTROLLER] Photo message sent successfully');
      AppLogger.info('📊 [CHAT CONTROLLER] Response success: ${response.success}');
      AppLogger.info('🆔 [CHAT CONTROLLER] Message ID: ${response.data.id}');
      AppLogger.info('📝 [CHAT CONTROLLER] Message text: ${response.data.text}');
      AppLogger.info('🏷️ [CHAT CONTROLLER] Message type: ${response.data.type}');
      AppLogger.info('🖼️ [CHAT CONTROLLER] Response images: ${response.data.images}');

      // Add the sent photo message to the messages list
      messages.add({
        'id': response.data.id,
        'text': response.data.text,
        'type': response.data.type,
        'sender': response.data.sender,
        'createdAt': response.data.createdAt,
        'isSentByMe': true,
      });
      
      // Also add to chatMessages for reactive UI
      try {
        // The sender is a String (sender ID) from the API response
        final senderId = response.data.sender;
        
        // Log the processed image URLs
        final processedImages = _processImageUrls(response.data.images);
        AppLogger.info('🔄 [CHAT CONTROLLER] Processed photo URLs: $processedImages');
        
        final photoMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '', // API doesn't provide email in response
            image: [], // API doesn't provide image list in response
            firstName: '', // API doesn't provide firstName in response
            lastName: '', // API doesn't provide lastName in response
          ),
          text: response.data.text,
          type: response.data.type,
          images: processedImages,
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: response.data.createdAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: response.data.createdAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        
        _addMessageToLists(photoMessage, legacyMessage: {
          'id': photoMessage.id,
          'text': photoMessage.text,
          'type': photoMessage.type,
          'sender': photoMessage.sender.toJson(),
          'createdAt': photoMessage.createdAt,
          'isSentByMe': true,
          'images': photoMessage.images,
        });
        
        AppLogger.info('✅ [CHAT CONTROLLER] Photo message added to reactive UI');
      } catch (e) {
        _handleApiError('createPhotoMessageObject', e);
      }
      

    } catch (e) {
      _handleApiError('takeAndSendPhoto', e);
      imageUploadError.value = e.toString();
      
      // Show error feedback
      _showErrorSnackbar('Photo Send Failed', e.toString());
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
  
  /// Initialize WebSocket connection
  void _initializeSocket() {
    try {
      AppLogger.info('🔌 [SOCKET] Initializing WebSocket connection...');
      
      // Get the base URL without /api/v1 for socket connection
      final socketUrl = AppUrls.socketUrl;
      AppLogger.info('🌐 [SOCKET] Socket URL: $socketUrl');
      
      // Use the user ID from LocalStorage (from access token)
      final userId = _getCurrentUserId();
      AppLogger.info('👤 [SOCKET] User ID: $userId');
      
      socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders({
              'Authorization': 'Bearer ${LocalStorage.token}',
              'user-id': userId,
            })
            .build(),
      );
      
      _setupSocketEvents();
      
      // Connect to socket
      AppLogger.info('🔗 [SOCKET] Connecting to WebSocket...');
      socket?.connect();
      
    } catch (e) {
      _handleApiError('initializeSocket', e);
      connectionStatus.value = 'Connection Error';
    }
  }
  
  /// Setup socket event listeners
  void _setupSocketEvents() {
    if (socket == null) return;
    
    // Connection events
    socket?.onConnect((_) {
      AppLogger.info('✅ [SOCKET] WebSocket connected successfully!');
      isConnected.value = true;
      connectionStatus.value = 'Connected';
      
      // Join the chat room when connected
      if (chatId.isNotEmpty) {
        AppLogger.info('🏠 [SOCKET] Joining chat room: $chatId');
        _joinChatRoom();
      } else {
        AppLogger.warning('⚠️ [SOCKET] No chat ID available to join room');
      }
    });
    
    socket?.onDisconnect((_) {
      AppLogger.info('❌ [SOCKET] WebSocket disconnected');
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
    });
    
    socket?.onConnectError((data) {
      AppLogger.error('❌ [SOCKET] WebSocket connection error: $data');
      isConnected.value = false;
      connectionStatus.value = 'Connection Error';
    });
    
    socket?.onError((data) {
      isConnected.value = false;
      connectionStatus.value = 'Error';
    });
    
    // Get user ID for dynamic event names
    final userId = _getCurrentUserId();
    
    // Dynamic user-specific events only
    _setupDynamicEventListeners(userId);
  }
  
  /// Setup dynamic event listeners with user ID
  void _setupDynamicEventListeners(String userId) {
    AppLogger.info('🎧 [SOCKET] Setting up dynamic event listeners for user: $userId');
    
    // Dynamic user-specific events
    socket?.on('newChat::$userId', (data) {
      AppLogger.info('🆕 [SOCKET] Received newChat event');
      _handleNewChat(data);
    });
    
    socket?.on('chatListUpdate::$userId', (data) {
      AppLogger.info('📋 [SOCKET] Received chatListUpdate event');
      _handleChatListUpdate(data);
    });
    
    socket?.on('notification::$userId', (data) {
      AppLogger.info('🔔 [SOCKET] Received notification event');
      _handleNotification(data);
    });
    
    socket?.on('chatMuteStatus::$userId', (data) {
      AppLogger.info('🔇 [SOCKET] Received chatMuteStatus event');
      _handleChatMuteStatus(data);
    });
    
    socket?.on('userBlockStatus::$userId', (data) {
      AppLogger.info('🚫 [SOCKET] Received userBlockStatus event');
      _handleUserBlockStatus(data);
    });
    
    socket?.on('newMessage::$userId', (data) {
      AppLogger.info('📨 [SOCKET] Received newMessage event');
      _handleNewMessage(data);
    });
    
    socket?.on('messageDelivered::$userId', (data) {
      AppLogger.info('📤 [SOCKET] Received messageDelivered event');
      _handleMessageDelivered(data);
    });
    
    socket?.on('messageRead::$userId', (data) {
      AppLogger.info('👁️ [SOCKET] Received messageRead event');
      _handleMessageRead(data);
    });
    
    socket?.on('userTyping::$userId', (data) {
      AppLogger.info('⌨️ [SOCKET] Received userTyping event');
      _handleUserTyping(data);
    });
    
    socket?.on('userStoppedTyping::$userId', (data) {
      AppLogger.info('⏹️ [SOCKET] Received userStoppedTyping event');
      _handleUserStoppedTyping(data);
    });
    
    AppLogger.info('✅ [SOCKET] All dynamic event listeners setup complete');
  }
  
  /// Join chat room
  void _joinChatRoom() {
    if (socket == null || !isConnected.value || chatId.isEmpty) {
      AppLogger.warning('⚠️ [SOCKET] Cannot join chat room - socket: ${socket != null}, connected: ${isConnected.value}, chatId: $chatId');
      return;
    }
    
    try {
      AppLogger.info('🏠 [SOCKET] Emitting joinChat event for chat: $chatId');
      socket?.emit('joinChat', {
        'chatId': chatId,
        'userId': currentUserId.value,
      });
      AppLogger.info('✅ [SOCKET] Successfully joined chat room: $chatId');
      
    } catch (e) {
      _handleApiError('joinChatRoom', e);
    }
  }
  
  /// Handle new message received via WebSocket
  void _handleNewMessage(dynamic data) {
    try {
      AppLogger.info('📨 [SOCKET] Handling new message: $data');
      
      final messageData = data as Map<String, dynamic>;
      
      // Safely extract each field with type checking
      String messageId = '';
      String senderId = '';
      String text = '';
      String type = 'text';
      
      try {
        messageId = messageData['id']?.toString() ?? '';
      // ignore: empty_catches
      } catch (e) { }
      
      try {
        senderId = messageData['sender']?.toString() ?? '';
      // ignore: empty_catches
      } catch (e) { }
      
      try {
        text = messageData['text']?.toString() ?? '';
      // ignore: empty_catches
      } catch (e) { }
      
      try {
        type = messageData['type']?.toString() ?? 'text';
      // ignore: empty_catches
      } catch (e) {
      }
      
      DateTime parsedCreatedAt = DateTime.now();
      try {
        final createdAtString = messageData['createdAt']?.toString();
        if (createdAtString != null && createdAtString.isNotEmpty) {
          parsedCreatedAt = DateTime.parse(createdAtString);
        }
      // ignore: empty_catches
      } catch (e) { }
      
      // Log extracted message data for debugging
      AppLogger.info('📝 [SOCKET] Extracted message - ID: $messageId, Sender: $senderId, Text: $text, Type: $type');
      
      // Validate critical fields
      if (messageId.isEmpty) {
        AppLogger.warning('⚠️ [SOCKET] Message rejected: Empty message ID');
        return;
      }
      
      if (senderId.isEmpty) {
        AppLogger.warning('⚠️ [SOCKET] Message rejected: Empty sender ID');
        return;
      }
      
      // Don't add message if it's sent by current user (already in list)
      if (senderId == currentUserId.value) {
        AppLogger.info('🔄 [SOCKET] Message ignored: Sent by current user');
        return;
      }
      
      // Check if message already exists to prevent duplicates
      final existingMessage = chatMessages.any((msg) => msg.id == messageId);
      if (existingMessage) {
        AppLogger.info('🔄 [SOCKET] Message ignored: Already exists in list');
        return;
      }
      
      // Add message to the chatMessages list (used by UI)
      try {
        final receivedMessage = Message(
          id: messageId,
          chatId: chatId,
          sender: MessageSender(
            id: senderId,
            email: '',
            image: [],
            firstName: '',
            lastName: '',
          ),
          text: text,
          type: type,
          read: false,
          isDeleted: false,
          isPinned: false,
          replyTo: null,
          iconViewed: [],
          createdAt: parsedCreatedAt,
          pinnedByUsers: [],
          deletedForUsers: [],
          reactions: [],
          updatedAt: parsedCreatedAt,
          v: 0,
          isPinnedByCurrentUser: false,
        );
        
        _addMessageToLists(receivedMessage);
        AppLogger.info('✅ [SOCKET] Message added to UI: $messageId (Total: ${chatMessages.length})');
        
      } catch (e) {
        _handleApiError('createMessageObject', e);
        return; // Don't proceed if message creation fails
      }
      
      // Mark message as delivered
      _markMessageAsDelivered(messageId);
      
    } catch (e) {
      _handleApiError('handleNewMessage', e);
    }
  }
  
  /// Handle message delivered event
  void _handleMessageDelivered(dynamic data) {
    try {
      // Update message status in UI if needed
      // You can add message status tracking here
      
    } catch (e) {
      _handleApiError('handleMessageDelivered', e);
    }
  }
  
  /// Handle message read event
  void _handleMessageRead(dynamic data) {
    try {
      // Update message status in UI if needed
      // You can add message status tracking here
      
    } catch (e) {
      _handleApiError('handleMessageRead', e);
    }
  }
  
  /// Handle user typing event
  void _handleUserTyping(dynamic data) {
    try {
      final typingData = data as Map<String, dynamic>;
      final userId = typingData['userId'] ?? '';
      
      if (userId == participantId.value) {
        isParticipantTyping.value = true;
        typingStatus.value = '${participantName.value} is typing...';
      }
      
    } catch (e) {
      _handleApiError('handleUserTyping', e);
    }
  }
  
  /// Handle user stopped typing event
  void _handleUserStoppedTyping(dynamic data) {
    try {
      final typingData = data as Map<String, dynamic>;
      final userId = typingData['userId'] ?? '';
      
      if (userId == participantId.value) {
        isParticipantTyping.value = false;
        typingStatus.value = '';
      }
      
    } catch (e) {
      _handleApiError('handleUserStoppedTyping', e);
    }
  }
  
  /// Mark message as delivered
  void _markMessageAsDelivered(String messageId) {
    if (!_isSocketConnected()) return;
    
    try {
      final userId = _getCurrentUserId();
      _logSocketEvent('markMessageDelivered', '📤', 'Message ID: $messageId, Chat ID: $chatId');
      socket?.emit('markMessageDelivered', {
        'messageId': messageId,
        'chatId': chatId,
        'userId': userId,
      });
      _logSocketEvent('markMessageDelivered sent', '✅');
      
    } catch (e) {
      _handleApiError('markMessageDelivered', e);
    }
  }
  
  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (!_isSocketConnected()) return;
    
    try {
      final userId = _getCurrentUserId();
      _logSocketEvent('markMessageRead', '📖', 'Message ID: $messageId, Chat ID: $chatId');
      socket?.emit('markMessageRead', {
        'messageId': messageId,
        'chatId': chatId,
        'userId': userId,
      });
      _logSocketEvent('markMessageRead sent', '✅');
      
    } catch (e) {
      _handleApiError('markMessageRead', e);
    }
  }
  
  /// Send typing indicator
  void sendTypingIndicator() {
    if (!_isSocketConnected()) {
      _logSocketEvent('Cannot send typing indicator', '⚠️', 'Socket: ${socket != null}, Connected: ${isConnected.value}');
      return;
    }
    
    try {
      final userId = _getCurrentUserId();
      _logSocketEvent('Sending typing indicator', '⌨️', 'User: $userId, Chat: $chatId');
      socket?.emit('typing', {
        'chatId': chatId,
        'userId': userId,
      });
      _logSocketEvent('Typing indicator sent', '✅');
      
    } catch (e) {
      _handleApiError('sendTypingIndicator', e);
    }
  }
  
  /// Send stopped typing indicator
  void sendStoppedTypingIndicator() {
    if (!_isSocketConnected()) {
      _logSocketEvent('Cannot send stopped typing indicator', '⚠️', 'Socket: ${socket != null}, Connected: ${isConnected.value}');
      return;
    }
    
    try {
      final userId = _getCurrentUserId();
      _logSocketEvent('Sending stopped typing indicator', '⏹️', 'User: $userId, Chat: $chatId');
      socket?.emit('stopTyping', {
        'chatId': chatId,
        'userId': userId,
      });
      _logSocketEvent('Stopped typing indicator sent', '✅');
      
    } catch (e) {
      _handleApiError('sendStoppedTypingIndicator', e);
    }
  }
  
  /// Disconnect WebSocket
  void _disconnectSocket() {
    if (socket != null) {
      _logSocketEvent('Disconnecting WebSocket', '🔌');
      socket?.disconnect();
      socket?.dispose();
      socket = null;
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      _logSocketEvent('WebSocket disconnected', '✅');
    }
  }
  
  /// Reconnect WebSocket
  void reconnectSocket() {
    _logSocketEvent('Reconnecting WebSocket', '🔄');
    _disconnectSocket();
    _initializeSocket();
  }
  
  /// Handle new chat event
  void _handleNewChat(dynamic data) {
    try {
      _logSocketEvent('Handling new chat event', '🆕', data.toString());
      
      if (data is Map<String, dynamic>) {
        final chatId = data['chatId']?.toString() ?? '';
        final chatName = data['chatName']?.toString() ?? '';
        _logSocketEvent('New chat details', '📝', 'ID: $chatId, Name: $chatName');
      }
    } catch (e) {
      _handleApiError('handleNewChat', e);
    }
  }
  
  /// Handle chat list update event
  void _handleChatListUpdate(dynamic data) {
    try {
      _logSocketEvent('Handling chat list update', '📋', data.toString());
      
      if (data is Map<String, dynamic>) {
        final updateType = data['updateType']?.toString() ?? '';
        final receivedChatId = data['chatId']?.toString() ?? '';
        _logSocketEvent('Chat list update', '📝', 'Type: $updateType, Chat ID: $receivedChatId');
        
        // Check if this update is for the current active chat
        if (receivedChatId == chatId && chatId.isNotEmpty) {
          _logSocketEvent('Refreshing messages for current chat', '🔄', 'Chat ID: $chatId');
          
          // Refresh messages to get the latest updates
          fetchMessages();
        }
      }
    } catch (e) {
      _handleApiError('handleChatListUpdate', e);
    }
  }
  
  /// Handle notification event
  void _handleNotification(dynamic data) {
    try {
      _logSocketEvent('Handling notification', '🔔', data.toString());
      
      if (data is Map<String, dynamic>) {
        final notificationType = data['type']?.toString() ?? '';
        final message = data['message']?.toString() ?? '';
        final receivedChatId = data['chatId']?.toString() ?? '';
        _logSocketEvent('Notification details', '📝', 'Type: $notificationType, Message: $message, Chat ID: $receivedChatId');
        
        // Check if this notification is for the current active chat
        if (receivedChatId == chatId && chatId.isNotEmpty) {
          _logSocketEvent('Refreshing messages due to notification', '🔄', 'Chat ID: $chatId');
          
          // Refresh messages to get the latest updates
          fetchMessages();
        }
      }
    } catch (e) {
      _handleApiError('handleNotification', e);
    }
  }
  
  /// Handle chat mute status event
  void _handleChatMuteStatus(dynamic data) {
    try {
      _logSocketEvent('Handling chat mute status', '🔇', data.toString());
      // TODO: Handle chat mute/unmute
      // This could update the UI to show muted status
      // For now, just log the event for debugging
      if (data is Map<String, dynamic>) {
        final chatId = data['chatId']?.toString() ?? '';
        final isMuted = data['isMuted']?.toString() ?? '';
        _logSocketEvent('Chat mute status', '📝', 'Chat ID: $chatId, Is Muted: $isMuted');
      }
    } catch (e) {
      _handleApiError('handleChatMuteStatus', e);
    }
  }
  
  /// Handle user block status event
  void _handleUserBlockStatus(dynamic data) {
    try {
      _logSocketEvent('Handling user block status', '🚫', data.toString());
      // TODO: Handle user block/unblock
      // This could update the UI to show blocked status or restrict messaging
      // For now, just log the event for debugging
      if (data is Map<String, dynamic>) {
        final userId = data['userId']?.toString() ?? '';
        final isBlocked = data['isBlocked']?.toString() ?? '';
        final chatId = data['chatId']?.toString() ?? '';
        _logSocketEvent('User block status', '📝', 'User ID: $userId, Is Blocked: $isBlocked, Chat ID: $chatId');
      }
    } catch (e) {
      _handleApiError('handleUserBlockStatus', e);
    }
  }
  
  /// Process image URLs - returns relative URLs as-is for backend processing
  List<String> _processImageUrls(List<String>? images) {
    if (images == null || images.isEmpty) {
      return [];
    }
    return images;
  }

  // HELPER METHODS FOR REFACTORING

  /// Get current user ID with fallbacks
  String _getCurrentUserId() {
    return LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
  }


  /// Add message to both message lists and update UI
  void _addMessageToLists(Message message, {Map<String, dynamic>? legacyMessage}) {
    // Add to chatMessages for reactive UI
    chatMessages.add(message);
    
    // Add to legacy messages list for backward compatibility
    if (legacyMessage != null) {
      messages.add(legacyMessage);
    } else {
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
    
    // Force UI update
    chatMessages.refresh();
  }

  /// Show error snackbar with consistent styling
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Check if socket is connected and available
  bool _isSocketConnected() {
    return socket != null && isConnected.value;
  }

  /// Log socket event with consistent format
  void _logSocketEvent(String eventName, String emoji, [String? additionalInfo]) {
    String logMessage = '$emoji [SOCKET] $eventName';
    if (additionalInfo != null) {
      logMessage += ' - $additionalInfo';
    }
    AppLogger.info(logMessage);
  }

  /// Handle API error with consistent logging and error setting
  void _handleApiError(String context, dynamic error, {String? errorVariable}) {
    AppLogger.error('❌ [$context] Error: $error');
    if (errorVariable != null) {
      // This would need to be implemented with reflection or passed as a callback
      // For now, we'll just log it
      AppLogger.error('❌ [$context] Error variable set: $errorVariable');
    }
  }
}
