import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/snackbar/snackbar_controller.dart';
import '../controller/chat_controller.dart';

class ChatConversationView extends StatefulWidget {
  const ChatConversationView({super.key});

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ChatController _chatController = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    
    // Debug logging
    print('🚀 [CHAT VIEW] Send button pressed');
    print('📝 [CHAT VIEW] Message content: "$message"');
    print('💬 [CHAT VIEW] Has chat: ${_chatController.hasChat}');
    print('🆔 [CHAT VIEW] Chat ID: "${_chatController.chatId}"');
    print('👥 [CHAT VIEW] Participants: ${_chatController.participants}');
    
    if (message.isEmpty) {
      print('⚠️ [CHAT VIEW] Cannot send - message is empty');
      Get.snackbar(
        'Empty Message',
        'Please type a message before sending',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }
    
    if (!_chatController.hasChat) {
      print('⚠️ [CHAT VIEW] Cannot send - no chat available');
      Get.snackbar(
        'No Chat',
        'Chat is not ready yet. Please wait...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }
    
    print('✅ [CHAT VIEW] Sending message...');
    _chatController.sendTextMessage(message);
    _messageController.clear();
  }

  void _handleImageAttachment() {
    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Select Image Source',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.blue),
              title: const Text('Gallery', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _chatController.pickAndSendImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('Camera', style: TextStyle(color: Colors.white)),
              onTap: () {
                Get.back();
                _chatController.takeAndSendPhoto();
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2E3A59),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Safe navigation back
                      if (Get.isRegistered<SnackbarController>()) {
                        Get.back();
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Profile image
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop&crop=face'
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Chat display name
                  Expanded(
                    child: Obx(() {
                      final displayName = _chatController.getChatDisplayName();
                      final hasChat = _chatController.hasChat;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'PlayfairDisplay',
                            ),
                          ),
                          Text(
                            hasChat ? 'Online' : 'Creating chat...',
                            style: TextStyle(
                              color: hasChat ? Colors.green : Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                  
                  const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
            ),
            
            // Chat messages
            Expanded(
              child: Obx(() {
                // Show loading indicator while creating chat
                if (_chatController.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D7AFF)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Creating chat...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show error message if chat creation failed
                if (_chatController.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to create chat',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _chatController.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _chatController.retryCreateChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5D7AFF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show message if no chat is available
                if (!_chatController.hasChat) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          color: Colors.white54,
                          size: 48,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No chat available',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show loading indicator while fetching messages
                if (_chatController.isLoadingMessages.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5D7AFF)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading messages...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                // Show messages from the fetched chat messages
                if (_chatController.chatMessages.isEmpty) {
                  return ListView(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    children: [
                      _buildReceivedMessage(
                        message: 'Chat created successfully! Start your conversation now.',
                        time: 'Just now',
                        showAvatar: true,
                      ),
                    ],
                  );
                }
                
                return ListView(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    // Show all messages
                    ..._chatController.chatMessages.map((message) {
                      final isSentByMe = message.sender.id == _chatController.currentUserId.value;
                      final messageText = message.text;
                      final messageType = message.type;
                      
                      // Format time using the message's formattedTime getter
                      String timeString = message.formattedTime;
                      
                      if (isSentByMe) {
                        // Sent messages appear on the RIGHT side
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 280, // Limit message width
                              ),
                              margin: const EdgeInsets.only(left: 60, right: 8),
                              child: _buildSentMessage(
                                message: messageText,
                                time: timeString,
                                messageType: messageType,
                              ),
                            ),
                          ),
                        );
                      } else {
                        // Received messages appear on the LEFT side
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: const BoxConstraints(
                                maxWidth: 280, // Limit message width
                              ),
                              margin: const EdgeInsets.only(right: 60, left: 8),
                              child: _buildReceivedMessage(
                                message: messageText,
                                time: timeString,
                                showAvatar: true, // Show avatar for received messages
                                messageType: messageType,
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ],
                );
              }),
            ),
            
            // Message input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E3A59),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  // Image attachment button
                  IconButton(
                    icon: const Icon(
                      Icons.image,
                      color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: _handleImageAttachment,
                  ),
                  const SizedBox(width: 8),
                  
                  // Text input field
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF21293F),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.white54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 8),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                        onSubmitted: (_) => _handleSendMessage(),
                      ),
                    ),
                  ),
                  
                  // Send button
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF5D7AFF),
                      size: 28,
                    ),
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

      Widget _buildSentMessage({
        required String message,
        required String time,
        bool showDeliveryStatus = true,
        String messageType = 'text',
      }) {
        final isImageMessage = messageType == 'image' || messageType == 'mixed' || messageType == 'custom';
        
        return Container(
          padding: isImageMessage ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5D7AFF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isImageMessage && message.isNotEmpty) ...[
                // Image placeholder
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.image,
                    color: Colors.white70,
                    size: 40,
                  ),
                ),
                if (message.isNotEmpty) const SizedBox(height: 8),
              ],
              if (message.isNotEmpty)
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    height: 1.3,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (showDeliveryStatus) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.done_all,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      }

      Widget _buildReceivedMessage({
        required String message,
        required String time,
        bool showAvatar = false,
        String messageType = 'text',
      }) {
        final isImageMessage = messageType == 'image' || messageType == 'mixed' || messageType == 'custom';
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (showAvatar)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 8, bottom: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face'
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            
            Flexible(
              child: Container(
                padding: isImageMessage ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4A6B),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isImageMessage && message.isNotEmpty) ...[
                      // Image placeholder
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image,
                          color: Colors.white54,
                          size: 40,
                        ),
                      ),
                      if (message.isNotEmpty) const SizedBox(height: 8),
                    ],
                    if (message.isNotEmpty)
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }
}