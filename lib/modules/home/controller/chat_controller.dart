import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  
  // Getters
  bool get hasChat => chatResponse.value != null;
  String get chatId => chatResponse.value?.data.id ?? '';
  List<String> get participants => chatResponse.value?.data.participants ?? [];
  
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
          errorMessage.value = 'Missing participant information';
        }
      } else {
        errorMessage.value = 'No chat information provided';
      }
      
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
    
    
    try {
      
      
      // Debug: Check all LocalStorage authentication data
      
      // Send only the suggested user's ID (from home suggestion photo card)
      if (participantId.value.isNotEmpty && participantId.value != 'null') {
      } else {
        // If no valid participant ID, show error and don't proceed
        Get.snackbar(
          'Chat Error',
          'No valid participant found for chat',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
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
      AppLogger.error('❌ ERROR CREATING CHAT ===');
      AppLogger.error('Error details: $e');
      AppLogger.error('Error type: ${e.runtimeType}');
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
      AppLogger.warning('[CHAT CONTROLLER] Error fetching messages (this may be normal for new chats): $e');
      // For new chats, it's normal to have no messages yet
      // Clear any error messages and show empty chat
      messages.clear();
      chatMessages.clear();
      
      // Force UI update
      chatMessages.refresh();
      
      // Only show error snackbar if it's not a 400 error (which is normal for new chats)
      if (!e.toString().contains('400') && !e.toString().contains('Client error')) {
        Get.snackbar(
          'Chat Info',
          'Starting new conversation...',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      }
    } finally {
      isLoadingMessages.value = false;
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
        chatMessages.add(sentMessage);
        
        // Force UI update
        chatMessages.refresh();
        
        AppLogger.info('[CHAT CONTROLLER] Successfully created and added sent Message object');
      } catch (e) {
        AppLogger.error('[CHAT CONTROLLER] Error creating sent Message object: $e');
        AppLogger.error('[CHAT CONTROLLER] Message object creation failed with response: ${response.data}');
      }
      
      
      // Emit message via WebSocket for real-time delivery with dynamic user ID
      if (isConnected.value) {
        try {
          final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
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
          AppLogger.error('❌ Error emitting message via WebSocket: $e');
        }
      } else {
        AppLogger.warning('⚠️ WebSocket not connected, message not sent via real-time');
      }

    } catch (e) {
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


      // For now, we'll use a placeholder URL since we don't have image upload functionality
      // In a real app, you would upload the image to a server and get the URL
      final imageUrl = 'file://${imageFile.path}';
      

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
      
      // Also add to chatMessages for reactive UI
      try {
        final senderData = response.data.sender as Map<String, dynamic>;
        
        final imageMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderData['_id']?.toString() ?? senderData['id']?.toString() ?? '',
            email: senderData['email']?.toString() ?? '',
            image: senderData['image'] != null 
                ? List<String>.from(senderData['image'].map((e) => e.toString())) 
                : [],
            firstName: senderData['firstName']?.toString() ?? '',
            lastName: senderData['lastName']?.toString() ?? '',
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
        
        chatMessages.add(imageMessage);
        
        // Force UI update
        chatMessages.refresh();
        
        AppLogger.info('[CHAT CONTROLLER] Image message added to reactive UI');
      } catch (e) {
        AppLogger.error('[CHAT CONTROLLER] Error creating image Message object: $e');
      }
      

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
      
      final XFile? photoFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (photoFile == null) {
        return;
      }

      isImageUploading.value = true;
      imageUploadError.value = '';


      // For now, we'll use a placeholder URL since we don't have image upload functionality
      // In a real app, you would upload the image to a server and get the URL
      final photoUrl = 'file://${photoFile.path}';
      

      final SendMessageResponse response = await _sendMessageService.sendImageMessage(
        chatId: chatId,
        imageUrl: photoUrl,
        caption: '', // You can add caption functionality later
      );


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
        final senderData = response.data.sender as Map<String, dynamic>;
        
        final photoMessage = Message(
          id: response.data.id,
          chatId: chatId,
          sender: MessageSender(
            id: senderData['_id']?.toString() ?? senderData['id']?.toString() ?? '',
            email: senderData['email']?.toString() ?? '',
            image: senderData['image'] != null 
                ? List<String>.from(senderData['image'].map((e) => e.toString())) 
                : [],
            firstName: senderData['firstName']?.toString() ?? '',
            lastName: senderData['lastName']?.toString() ?? '',
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
        
        chatMessages.add(photoMessage);
        
        // Force UI update
        chatMessages.refresh();
        
        AppLogger.info('[CHAT CONTROLLER] Photo message added to reactive UI');
      } catch (e) {
        AppLogger.error('[CHAT CONTROLLER] Error creating photo Message object: $e');
      }
      

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
  
  /// Initialize WebSocket connection
  void _initializeSocket() {
    try {
      AppLogger.info('🔌 [SOCKET] Initializing WebSocket connection...');
      
      // Get the base URL without /api/v1 for socket connection
      final socketUrl = AppUrls.socketUrl;
      AppLogger.info('🌐 [SOCKET] Socket URL: $socketUrl');
      
      // Use the user ID from LocalStorage (from access token)
      final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
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
      AppLogger.error('❌ [SOCKET] Error initializing WebSocket: $e');
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
    final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
    
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
      AppLogger.error('❌ [SOCKET] Error joining chat room: $e');
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
        
        chatMessages.add(receivedMessage);
        AppLogger.info('✅ [SOCKET] Message added to UI: $messageId (Total: ${chatMessages.length})');
        
        // Force UI update
        chatMessages.refresh();
        
      } catch (e) {
        AppLogger.error('❌ [SOCKET] Error creating message object: $e');
        return; // Don't proceed if message creation fails
      }
      
      // Mark message as delivered
      _markMessageAsDelivered(messageId);
      
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling new message: $e');
    }
  }
  
  /// Handle message delivered event
  void _handleMessageDelivered(dynamic data) {
    try {
      // Update message status in UI if needed
      // You can add message status tracking here
      
    } catch (e) {
      AppLogger.error('❌ Error handling message delivered: $e');
    }
  }
  
  /// Handle message read event
  void _handleMessageRead(dynamic data) {
    try {
      // Update message status in UI if needed
      // You can add message status tracking here
      
    } catch (e) {
      AppLogger.error('❌ Error handling message read: $e');
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
      AppLogger.error('❌ Error handling user typing: $e');
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
      AppLogger.error('❌ Error handling user stopped typing: $e');
    }
  }
  
  /// Mark message as delivered
  void _markMessageAsDelivered(String messageId) {
    if (socket == null || !isConnected.value) return;
    
    try {
      final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
      socket?.emit('markMessageDelivered', {
        'messageId': messageId,
        'chatId': chatId,
        'userId': userId,
      });
      
    } catch (e) {
      AppLogger.error('❌ Error marking message as delivered: $e');
    }
  }
  
  /// Mark message as read
  void markMessageAsRead(String messageId) {
    if (socket == null || !isConnected.value) return;
    
    try {
      final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
      socket?.emit('markMessageRead', {
        'messageId': messageId,
        'chatId': chatId,
        'userId': userId,
      });
      
    } catch (e) {
      AppLogger.error('❌ Error marking message as read: $e');
    }
  }
  
  /// Send typing indicator
  void sendTypingIndicator() {
    if (socket == null || !isConnected.value) {
      AppLogger.warning('⚠️ [SOCKET] Cannot send typing indicator - socket: ${socket != null}, connected: ${isConnected.value}');
      return;
    }
    
    try {
      final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
      AppLogger.info('⌨️ [SOCKET] Sending typing indicator for user: $userId in chat: $chatId');
      socket?.emit('typing', {
        'chatId': chatId,
        'userId': userId,
      });
      AppLogger.info('✅ [SOCKET] Typing indicator sent successfully');
      
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error sending typing indicator: $e');
    }
  }
  
  /// Send stopped typing indicator
  void sendStoppedTypingIndicator() {
    if (socket == null || !isConnected.value) {
      AppLogger.warning('⚠️ [SOCKET] Cannot send stopped typing indicator - socket: ${socket != null}, connected: ${isConnected.value}');
      return;
    }
    
    try {
      final userId = LocalStorage.userId.isNotEmpty ? LocalStorage.userId : currentUserId.value;
      AppLogger.info('⏹️ [SOCKET] Sending stopped typing indicator for user: $userId in chat: $chatId');
      socket?.emit('stopTyping', {
        'chatId': chatId,
        'userId': userId,
      });
      AppLogger.info('✅ [SOCKET] Stopped typing indicator sent successfully');
      
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error sending stopped typing indicator: $e');
    }
  }
  
  /// Disconnect WebSocket
  void _disconnectSocket() {
    if (socket != null) {
      AppLogger.info('🔌 [SOCKET] Disconnecting WebSocket...');
      socket?.disconnect();
      socket?.dispose();
      socket = null;
      isConnected.value = false;
      connectionStatus.value = 'Disconnected';
      AppLogger.info('✅ [SOCKET] WebSocket disconnected successfully');
    }
  }
  
  /// Reconnect WebSocket
  void reconnectSocket() {
    AppLogger.info('🔄 [SOCKET] Reconnecting WebSocket...');
    _disconnectSocket();
    _initializeSocket();
  }
  
  /// Handle new chat event
  void _handleNewChat(dynamic data) {
    try {
      AppLogger.info('🆕 [SOCKET] Handling new chat event: $data');
      // TODO: Handle new chat creation/update
      // This could refresh the chat list or update the current chat
      // For now, just log the event for debugging
      if (data is Map<String, dynamic>) {
        final chatId = data['chatId']?.toString() ?? '';
        final chatName = data['chatName']?.toString() ?? '';
        AppLogger.info('📝 [SOCKET] New chat details - ID: $chatId, Name: $chatName');
      }
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling new chat event: $e');
    }
  }
  
  /// Handle chat list update event
  void _handleChatListUpdate(dynamic data) {
    try {
      AppLogger.info('📋 [SOCKET] Handling chat list update: $data');
      
      if (data is Map<String, dynamic>) {
        final updateType = data['updateType']?.toString() ?? '';
        final receivedChatId = data['chatId']?.toString() ?? '';
        AppLogger.info('📝 [SOCKET] Chat list update - Type: $updateType, Chat ID: $receivedChatId');
        
        // Check if this update is for the current active chat
        if (receivedChatId == chatId && chatId.isNotEmpty) {
          AppLogger.info('🔄 [SOCKET] Refreshing messages for current chat: $chatId');
          
          // Refresh messages to get the latest updates
          fetchMessages();
        }
      }
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling chat list update: $e');
    }
  }
  
  /// Handle notification event
  void _handleNotification(dynamic data) {
    try {
      AppLogger.info('🔔 [SOCKET] Handling notification: $data');
      
      if (data is Map<String, dynamic>) {
        final notificationType = data['type']?.toString() ?? '';
        final message = data['message']?.toString() ?? '';
        final receivedChatId = data['chatId']?.toString() ?? '';
        AppLogger.info('📝 [SOCKET] Notification - Type: $notificationType, Message: $message, Chat ID: $receivedChatId');
        
        // Check if this notification is for the current active chat
        if (receivedChatId == chatId && chatId.isNotEmpty) {
          AppLogger.info('🔄 [SOCKET] Refreshing messages due to notification for current chat: $chatId');
          
          // Refresh messages to get the latest updates
          fetchMessages();
        }
      }
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling notification: $e');
    }
  }
  
  /// Handle chat mute status event
  void _handleChatMuteStatus(dynamic data) {
    try {
      AppLogger.info('🔇 [SOCKET] Handling chat mute status: $data');
      // TODO: Handle chat mute/unmute
      // This could update the UI to show muted status
      // For now, just log the event for debugging
      if (data is Map<String, dynamic>) {
        final chatId = data['chatId']?.toString() ?? '';
        final isMuted = data['isMuted']?.toString() ?? '';
        AppLogger.info('📝 [SOCKET] Chat mute status - Chat ID: $chatId, Is Muted: $isMuted');
      }
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling chat mute status: $e');
    }
  }
  
  /// Handle user block status event
  void _handleUserBlockStatus(dynamic data) {
    try {
      AppLogger.info('🚫 [SOCKET] Handling user block status: $data');
      // TODO: Handle user block/unblock
      // This could update the UI to show blocked status or restrict messaging
      // For now, just log the event for debugging
      if (data is Map<String, dynamic>) {
        final userId = data['userId']?.toString() ?? '';
        final isBlocked = data['isBlocked']?.toString() ?? '';
        final chatId = data['chatId']?.toString() ?? '';
        AppLogger.info('📝 [SOCKET] User block status - User ID: $userId, Is Blocked: $isBlocked, Chat ID: $chatId');
      }
    } catch (e) {
      AppLogger.error('❌ [SOCKET] Error handling user block status: $e');
    }
  }
}
