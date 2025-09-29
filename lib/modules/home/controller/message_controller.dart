import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/core/app_urls.dart';
import 'dart:math' as math;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../services/message_view_getChat_list_service.dart';
import '../models/message_view_getChat_list.dart';
import '../../../core/logger/app_logger.dart';
import '../../../local/storage_service.dart';
import '../../../config/app_routes.dart';

class MessageController extends GetxController {
  // Services
  final MessageViewGetChatListService _chatService = MessageViewGetChatListService();
  
  // Socket.io client
  IO.Socket? _socket;
  final RxBool isSocketConnected = false.obs;
  
  // Load chat list from API
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  
  // Controller state
  final RxBool isDisposed = false.obs;
  
  // Chat data
  final RxList<Chat> chatList = <Chat>[].obs;
  final RxList<Chat> filteredChatList = <Chat>[].obs;
  
  // Loading and error states
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  
  // Default profile image
  final String defaultProfileImage = 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face';

  @override
  void onInit() {
    super.onInit();
    _initializeStorage();
    _setupSearchListener();
    _initializeSocket();
    _loadChatList();
  }

  /// Initialize LocalStorage data
  Future<void> _initializeStorage() async {
    try {
      await LocalStorage.getAllPrefData();
      AppLogger.info('[MESSAGE CONTROLLER] LocalStorage data loaded');
      AppLogger.info('[MESSAGE CONTROLLER] User logged in: ${LocalStorage.isLogIn}');
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error loading LocalStorage data: $e');
    }
  }

  @override
  void onClose() {
    isDisposed.value = true;
    _disconnectSocket();
    searchController.dispose();
    super.onClose();
  }

  /// Load chat list from API
  Future<void> _loadChatList() async {
    isLoading.value = true;
    
    AppLogger.info('[MESSAGE CONTROLLER] Loading chat list...');
    
    // Check if token is available
    final token = LocalStorage.token;
    AppLogger.info('[MESSAGE CONTROLLER] Token available: ${token.isNotEmpty}');
    AppLogger.info('[MESSAGE CONTROLLER] Token length: ${token.length}');
    AppLogger.info('[MESSAGE CONTROLLER] Token preview: ${token.isNotEmpty ? '${token.substring(0, math.min(10, token.length))}...' : 'EMPTY'}');
    
    if (token.isEmpty) {
      AppLogger.error('[MESSAGE CONTROLLER] No authentication token found');
      errorMessage.value = 'Authentication required. Please login again.';
      isLoading.value = false;
      return;
    }
    
    try {
      final response = await _chatService.getChatList(token);  // Pass authentication token
      
      AppLogger.info('[MESSAGE CONTROLLER] API Response: $response');
      
      // Check if response has the expected structure
      if (response.containsKey('chats')) {
        // API returns chats directly: {"chats": [...]}
        final chatsList = response['chats'] as List;
        AppLogger.info('[MESSAGE CONTROLLER] Direct chats list length: ${chatsList.length}');
        
        if (chatsList.isNotEmpty) {
          chatList.assignAll(chatsList.map<Chat>((chat) => Chat.fromJson(chat)).toList());
          filteredChatList.assignAll(chatList); // Initialize filtered list with all chats
          AppLogger.info('[MESSAGE CONTROLLER] Loaded ${chatList.length} chats successfully');
          
          // Log first chat details for debugging
          if (chatList.isNotEmpty) {
            final firstChat = chatList.first;
            AppLogger.info('[MESSAGE CONTROLLER] First chat ID: ${firstChat.id}');
            AppLogger.info('[MESSAGE CONTROLLER] First chat participant: ${firstChat.participantName}');
            AppLogger.info('[MESSAGE CONTROLLER] First chat status: ${firstChat.status}');
          }
        } else {
          AppLogger.info('[MESSAGE CONTROLLER] Chats list is empty - no conversations yet');
          chatList.clear();
          filteredChatList.clear();
        }
      } else if (response['success'] == true && response.containsKey('data')) {
        // API returns structured response: {"success": true, "data": {"chats": [...]}}
        final data = response['data'];
        AppLogger.info('[MESSAGE CONTROLLER] Response data keys: ${data.keys.toList()}');
        AppLogger.info('[MESSAGE CONTROLLER] Chats data type: ${data['chats']?.runtimeType}');
        AppLogger.info('[MESSAGE CONTROLLER] Chats data: ${data['chats']}');
        
        if (data['chats'] != null) {
          final chatsList = data['chats'] as List;
          AppLogger.info('[MESSAGE CONTROLLER] Chats list length: ${chatsList.length}');
          
          if (chatsList.isNotEmpty) {
            chatList.assignAll(chatsList.map<Chat>((chat) => Chat.fromJson(chat)).toList());
            filteredChatList.assignAll(chatList); // Initialize filtered list with all chats
            AppLogger.info('[MESSAGE CONTROLLER] Loaded ${chatList.length} chats successfully');
            
            // Log first chat details for debugging
            if (chatList.isNotEmpty) {
              final firstChat = chatList.first;
              AppLogger.info('[MESSAGE CONTROLLER] First chat ID: ${firstChat.id}');
              AppLogger.info('[MESSAGE CONTROLLER] First chat participant: ${firstChat.participantName}');
              AppLogger.info('[MESSAGE CONTROLLER] First chat status: ${firstChat.status}');
            }
          } else {
            AppLogger.info('[MESSAGE CONTROLLER] Chats list is empty - no conversations yet');
            chatList.clear();
            filteredChatList.clear();
          }
        } else {
          AppLogger.warning('[MESSAGE CONTROLLER] No chats data in response');
          chatList.clear();
          filteredChatList.clear();
        }
      } else {
        errorMessage.value = response['message'] ?? 'Invalid response format';
        AppLogger.error('[MESSAGE CONTROLLER] Invalid response format: $response');
      }
    } catch (e) {
      // Handle different types of errors with specific messages
      errorMessage.value = 'Failed to load chats. Please try again.';
      AppLogger.error('[MESSAGE CONTROLLER] Error loading chat list: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// Refresh chat list
  Future<void> refreshChatList() async {
    await _loadChatList();
  }

  /// Refresh token data and retry loading chat list
  Future<void> refreshTokenAndRetry() async {
    AppLogger.info('[MESSAGE CONTROLLER] Refreshing token data and retrying...');
    await _initializeStorage();
    await _loadChatList();
  }

  void _setupSearchListener() {
    // Listen to search controller changes
    searchController.addListener(() {
      searchQuery.value = searchController.text.toLowerCase();
      _filterChats();
    });
  }

  void _filterChats() {
    if (searchQuery.value.isEmpty) {
      filteredChatList.assignAll(chatList);
    } else {
      final filtered = chatList.where((chat) {
        final name = chat.participantName.toLowerCase();
        return name.contains(searchQuery.value);
      }).toList();
      
      filteredChatList.assignAll(filtered);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _filterChats();
  }

  /// Get profile image URL for a chat
  String getProfileImage(Chat chat) {
    return chat.participantImage.isNotEmpty ? chat.participantImage.first : defaultProfileImage;
  }

  /// Get last message text for display (truncated like other messaging apps)
  String getLastMessageText(Chat chat) {
    if (chat.lastMessage == null) {
      return 'No messages yet';
    }
    
    String messageText = '';
    String messageType = '';
    
    // Handle different types of lastMessage
    if (chat.lastMessage is Map<String, dynamic>) {
      final messageData = chat.lastMessage as Map<String, dynamic>;
      messageText = messageData['content']?.toString() ?? '';
      messageType = messageData['type']?.toString() ?? 'text';
    } else if (chat.lastMessage is String) {
      messageText = chat.lastMessage.toString();
      messageType = 'text';
    } else {
      return 'No messages yet';
    }
    
    // Handle different message types
    if (messageText.isEmpty) {
      switch (messageType.toLowerCase()) {
        case 'image':
          return '📷 Photo';
        case 'video':
          return '🎥 Video';
        case 'audio':
          return '🎵 Audio';
        case 'file':
          return '📎 File';
        case 'voice':
          return '🎤 Voice message';
        default:
          return 'Message';
      }
    }
    
    // Truncate text messages like other messaging apps
    if (messageText.length > 30) {
      return '${messageText.substring(0, 30)}...';
    }
    
    return messageText;
  }

  /// Get unread message count for display
  String getUnreadCountText(Chat chat) {
    if (chat.unreadCount <= 0) {
      return '';
    }
    
    if (chat.unreadCount > 99) {
      return '99+';
    }
    
    return chat.unreadCount.toString();
  }

  /// Check if chat has unread messages
  bool hasUnreadMessages(Chat chat) {
    return chat.unreadCount > 0;
  }

  /// Get chat display status (online, offline, etc.)
  String getChatStatus(Chat chat) {
    // This could be enhanced with real online status from socket
    if (chat.isMuted) {
      return '🔇 Muted';
    }
    
    // Return empty string for now, can be enhanced with online status
    return '';
  }
  
  /// Format timestamp for display
  String formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inDays == 0) {
        return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error parsing time: $timeString, error: $e');
      return 'Just now';
    }
  }

  void navigateToChat({String? chatId, String? participantName, String? participantId}) {
    AppLogger.info('[MESSAGE CONTROLLER] Navigating to chat with:');
    AppLogger.info('  - chatId: $chatId');
    AppLogger.info('  - participantName: $participantName');
    AppLogger.info('  - participantId: $participantId');
    AppLogger.info('  - currentUserId: ${LocalStorage.userId}');
    
    if (chatId != null && participantName != null && participantId != null) {
      Get.toNamed(AppRoutes.chat, arguments: {
        'chatId': chatId,
        'participantName': participantName,
        'participantId': participantId,
        'currentUserId': LocalStorage.userId, // Add current user ID
      });
    } else {
      // Fallback navigation without specific chat data
      Get.toNamed(AppRoutes.chat, arguments: {
        'currentUserId': LocalStorage.userId, // Still include current user ID
      });
    }
  }

  /// Handle bottom navigation item taps
  void handleNavigation(int index) {
    // Handle navigation based on the selected index
    switch (index) {
      case 0: // Explore/Home tab
        Get.toNamed(AppRoutes.homeSuggestionView);
        break;
      case 1: // AI Assistant tab
        Get.toNamed(AppRoutes.aiAssistantView);
        break;
      case 2: // Messages tab (current tab)
        // Already on messages tab, do nothing or refresh
        break;
      case 3: // Profile tab
        Get.toNamed(AppRoutes.profileView);
        break;
    }
  }

  /// Initialize Socket.io connection
  void _initializeSocket() {
    try {
      final token = LocalStorage.token;
      if (token.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No token available for socket connection');
        return;
      }

      // Configure socket connection
      _socket = IO.io(AppUrls.socketUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {
          'token': token,
          'userId': LocalStorage.userId,
        },
      });

      // Set up socket event listeners
      _setupSocketListeners();

      // Connect to socket
      _socket?.connect();
      AppLogger.info('[MESSAGE CONTROLLER] Socket connection initialized');
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error initializing socket: $e');
    }
  }

  /// Set up socket event listeners
  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      AppLogger.info('[MESSAGE CONTROLLER] Socket connected successfully');
      isSocketConnected.value = true;
      
      // Join user-specific room
      final userId = LocalStorage.userId;
      if (userId.isNotEmpty) {
        _socket!.emit('joinUserRoom', {'userId': userId});
        AppLogger.info('[MESSAGE CONTROLLER] Joined user room: $userId');
      }
    });

    _socket!.onDisconnect((_) {
      AppLogger.info('[MESSAGE CONTROLLER] Socket disconnected');
      isSocketConnected.value = false;
    });

    _socket!.onConnectError((data) {
      AppLogger.error('[MESSAGE CONTROLLER] Socket connection error: $data');
      isSocketConnected.value = false;
    });

    _socket!.on('chatListUpdate', (data) {
      AppLogger.info('[MESSAGE CONTROLLER] Received chatListUpdate event: $data');
      _handleChatListUpdate(data);
    });

    _socket!.on('error', (data) {
      AppLogger.error('[MESSAGE CONTROLLER] Socket error: $data');
    });
  }

  /// Handle chat list update from socket.
  ///
  /// This method handles real-time chat list updates received via socket.io events.
  /// It supports multiple update types to provide a seamless real-time chat experience.
  ///
  /// **Event Data Structure:**
  /// The event data should be a Map<String, dynamic> with the following structure:
  /// ```json
  /// {
  ///   "userId": "current_user_id",           // Required: User ID for validation
  ///   "type": "update_type",                 // Required: Type of update
  ///   "chatId": "chat_id",                   // Required for most update types
  ///   // Additional fields based on update type
  /// }
  /// ```
  ///
  /// **Supported Update Types:**
  ///
  /// **1. "new_message"** - New message received
  /// Updates chat with new message information and sorts to top.
  /// - `lastMessage`: Message content/object
  /// - `updatedAt`: New timestamp
  /// - `isFromOtherUser`: Boolean (true if message from other user)
  ///
  /// **2. "read_status"** - Chat read status changed
  /// Updates the read status and optionally resets unread count.
  /// - `isRead`: Boolean (true if chat is read)
  ///
  /// **3. "unread_count"** - Unread message count changed
  /// Updates the unread count for a specific chat.
  /// - `unreadCount`: Integer (number of unread messages)
  ///
  /// **4. "chat_deleted"** - Chat was deleted
  /// Removes the chat from the chat list.
  ///
  /// **5. "mute_status"** - Chat mute status changed
  /// Updates the mute status for a chat.
  /// - `isMuted`: Boolean (true if chat is muted)
  ///
  /// **6. "block_status"** - Chat block status changed
  /// Updates the block status for a chat.
  /// - `isBlocked`: Boolean (true if chat is blocked)
  ///
  /// **7. "participant_update"** - Chat participants changed
  /// Refreshes the entire chat list when participants change.
  ///
  /// **8. "general"** - General update (fallback)
  /// Handles general updates and optional full refresh.
  /// - `refresh`: Boolean (true to trigger full list refresh)
  ///
  /// **Error Handling:**
  /// - All update types include comprehensive error handling
  /// - Falls back to full chat list refresh on errors
  /// - Logs all operations for debugging
  /// - Validates required fields before processing
  ///
  /// **Performance Considerations:**
  /// - Updates are performed in-memory for optimal performance
  /// - Only refreshes from API when necessary
  /// - Automatic sorting keeps most recent chats at top
  /// - Filtered list is updated automatically
  void _handleChatListUpdate(dynamic data) {
    try {
      final userId = LocalStorage.userId;
      if (userId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No user ID available for chat list update');
        return;
      }

      AppLogger.info('[MESSAGE CONTROLLER] Processing chatListUpdate event: $data');

      if (data is Map<String, dynamic>) {
        // Check if the update is for the current user
        if (data.containsKey('userId')) {
          final eventUserId = data['userId'].toString();
          if (eventUserId != userId) {
            AppLogger.info('[MESSAGE CONTROLLER] Chat list update not for current user ($eventUserId != $userId)');
            return;
          }
        }

        // Handle different types of updates
        final updateType = data['type']?.toString() ?? 'general';
        
        switch (updateType.toLowerCase()) {
          case 'new_message':
            _handleNewMessageUpdate(data);
            break;
          case 'read_status':
            _handleReadStatusUpdate(data);
            break;
          case 'unread_count':
            _handleUnreadCountUpdate(data);
            break;
          case 'chat_deleted':
            _handleChatDeletedUpdate(data);
            break;
          case 'mute_status':
            _handleMuteStatusUpdate(data);
            break;
          case 'block_status':
            _handleBlockStatusUpdate(data);
            break;
          case 'participant_update':
            _handleParticipantUpdate(data);
            break;
          case 'general':
          default:
            _handleGeneralUpdate(data);
            break;
        }
      } else {
        // Handle non-map data (legacy support)
        AppLogger.info('[MESSAGE CONTROLLER] Received legacy chat list update format');
        _handleGeneralUpdate(data);
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling chat list update: $e');
      // Fallback to general refresh on error
      _loadChatList();
    }
  }

  /// Handle new message update
  void _handleNewMessageUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for new message update');
        return;
      }

      AppLogger.info('[MESSAGE CONTROLLER] Handling new message update for chat: $chatId');
      
      // Find the chat in the current list
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        // Create a copy of the chat to modify
        final updatedChat = chatList[chatIndex];
        
        // Update last message if provided
        if (data.containsKey('lastMessage')) {
          updatedChat.lastMessage = data['lastMessage'];
        }
        
        // Update timestamp if provided
        if (data.containsKey('updatedAt')) {
          updatedChat.updatedAt = data['updatedAt'].toString();
        }
        
        // Increment unread count if message is from another user
        if (data['isFromOtherUser'] == true) {
          updatedChat.unreadCount = updatedChat.unreadCount + 1;
        }
        
        // Mark as unread if message is from another user
        if (data['isFromOtherUser'] == true) {
          updatedChat.isRead = false;
        }
        
        // Replace the chat in the list to trigger UI update
        chatList[chatIndex] = updatedChat;
        
        // Notify listeners that the list has changed
        chatList.refresh();
        
        AppLogger.info('[MESSAGE CONTROLLER] Updated chat $chatId with new message');
        
        // Sort the chat list to bring this chat to the top
        _sortChatList();
      } else {
        // Chat not found in current list, refresh the entire list
        AppLogger.info('[MESSAGE CONTROLLER] Chat $chatId not found in current list, refreshing');
        _loadChatList();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling new message update: $e');
    }
  }

  /// Handle read status update
  void _handleReadStatusUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for read status update');
        return;
      }

      AppLogger.info('[MESSAGE CONTROLLER] Handling read status update for chat: $chatId');
      
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        final isRead = data['isRead'] ?? true;
        chatList[chatIndex].isRead = isRead;
        
        // Reset unread count when marked as read
        if (isRead) {
          chatList[chatIndex].unreadCount = 0;
        }
        
        AppLogger.info('[MESSAGE CONTROLLER] Updated read status for chat $chatId: $isRead');
        chatList.refresh();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling read status update: $e');
    }
  }

  /// Handle unread count update
  void _handleUnreadCountUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for unread count update');
        return;
      }

      final unreadCount = data['unreadCount'] ?? 0;
      AppLogger.info('[MESSAGE CONTROLLER] Handling unread count update for chat: $chatId, count: $unreadCount');
      
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chatList[chatIndex].unreadCount = unreadCount;
        chatList[chatIndex].isRead = unreadCount == 0;
        
        AppLogger.info('[MESSAGE CONTROLLER] Updated unread count for chat $chatId: $unreadCount');
        chatList.refresh();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling unread count update: $e');
    }
  }

  /// Handle chat deleted update
  void _handleChatDeletedUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for chat deleted update');
        return;
      }

      AppLogger.info('[MESSAGE CONTROLLER] Handling chat deleted update for chat: $chatId');
      
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chatList.removeAt(chatIndex);
        AppLogger.info('[MESSAGE CONTROLLER] Removed deleted chat $chatId from list');
        _filterChats(); // Update filtered list as well
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling chat deleted update: $e');
    }
  }

  /// Handle mute status update
  void _handleMuteStatusUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for mute status update');
        return;
      }

      final isMuted = data['isMuted'] ?? false;
      AppLogger.info('[MESSAGE CONTROLLER] Handling mute status update for chat: $chatId, muted: $isMuted');
      
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chatList[chatIndex].isMuted = isMuted;
        AppLogger.info('[MESSAGE CONTROLLER] Updated mute status for chat $chatId: $isMuted');
        chatList.refresh();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling mute status update: $e');
    }
  }

  /// Handle block status update
  void _handleBlockStatusUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for block status update');
        return;
      }

      final isBlocked = data['isBlocked'] ?? false;
      AppLogger.info('[MESSAGE CONTROLLER] Handling block status update for chat: $chatId, blocked: $isBlocked');
      
      final chatIndex = chatList.indexWhere((chat) => chat.id == chatId);
      if (chatIndex != -1) {
        chatList[chatIndex].isBlocked = isBlocked;
        AppLogger.info('[MESSAGE CONTROLLER] Updated block status for chat $chatId: $isBlocked');
        chatList.refresh();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling block status update: $e');
    }
  }

  /// Handle participant update
  void _handleParticipantUpdate(Map<String, dynamic> data) {
    try {
      final chatId = data['chatId']?.toString();
      if (chatId == null || chatId.isEmpty) {
        AppLogger.warning('[MESSAGE CONTROLLER] No chatId provided for participant update');
        return;
      }

      AppLogger.info('[MESSAGE CONTROLLER] Handling participant update for chat: $chatId');
      
      // For participant updates, it's safer to refresh the entire chat
      // as participant data structure might change significantly
      _loadChatList();
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling participant update: $e');
    }
  }

  /// Handle general update (fallback)
  void _handleGeneralUpdate(dynamic data) {
    try {
      AppLogger.info('[MESSAGE CONTROLLER] Handling general chat list update');
      
      // Sort chat list based on the update
      _sortChatList();
      
      // Check if we need to refresh the entire list
      bool shouldRefresh = false;
      if (data is Map<String, dynamic>) {
        shouldRefresh = data['refresh'] == true;
      }
      
      if (shouldRefresh) {
        AppLogger.info('[MESSAGE CONTROLLER] General update requires full refresh');
        _loadChatList();
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling general update: $e');
      // Fallback to refresh on error
      _loadChatList();
    }
  }

  /// Sort chat list based on last message timestamp
  void _sortChatList() {
    try {
      // Sort chat list by updatedAt timestamp (most recent first)
      chatList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.updatedAt);
          final dateB = DateTime.parse(b.updatedAt);
          return dateB.compareTo(dateA); // Descending order (newest first)
        } catch (e) {
          AppLogger.error('[MESSAGE CONTROLLER] Error parsing date for sorting: $e');
          return 0;
        }
      });
      
      // Update filtered list as well
      _filterChats();
      
      AppLogger.info('[MESSAGE CONTROLLER] Chat list sorted successfully');
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error sorting chat list: $e');
    }
  }

  /// Disconnect socket connection
  void _disconnectSocket() {
    try {
      _socket?.disconnect();
      _socket = null;
      isSocketConnected.value = false;
      AppLogger.info('[MESSAGE CONTROLLER] Socket disconnected');
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error disconnecting socket: $e');
    }
  }
}
