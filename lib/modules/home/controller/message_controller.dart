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

  /// Handle chat list update from socket
  void _handleChatListUpdate(dynamic data) {
    try {
      final userId = LocalStorage.userId;
      if (userId.isEmpty) return;

      // Check if the update is for the current user
      if (data is Map<String, dynamic> && data.containsKey('userId')) {
        final eventUserId = data['userId'].toString();
        if (eventUserId == userId) {
          AppLogger.info('[MESSAGE CONTROLLER] Chat list update received for current user');
          
          // Sort chat list based on the update
          _sortChatList();
          
          // Optionally refresh the chat list if needed
          if (data['refresh'] == true) {
            _loadChatList();
          }
        }
      }
    } catch (e) {
      AppLogger.error('[MESSAGE CONTROLLER] Error handling chat list update: $e');
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
