import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter_emoji/flutter_emoji.dart';
import '../../../core/app_urls.dart';
import '../controller/chat_controller.dart';

class ChatConversationView extends StatefulWidget {
  final Map<String, dynamic>? arguments;
  
  const ChatConversationView({
    super.key,
    this.arguments,
  });

  @override
  _ChatConversationViewState createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  final ChatController _chatController = Get.put(ChatController());
  final TextEditingController _messageController = TextEditingController();
  List<Emoji>? _allEmojis;
  Timer? _typingTimer;
  bool _showEmojiPicker = false;
  
  // Cache for all emojis
  /// Get all emojis from the JSON_EMOJI data
  List<Emoji> _getAllEmojis() {
    if (_allEmojis != null) {
      return _allEmojis!;
    }
    
    _allEmojis = [];
    
    // Parse the JSON_EMOJI string
    final emojiMap = jsonDecode(EmojiParser.JSON_EMOJI) as Map<String, dynamic>;
    
    // Convert each entry to an Emoji object
    emojiMap.forEach((name, code) {
      _allEmojis!.add(Emoji(name, code));
    });
    
    return _allEmojis!;
  }
  
  void _showFullScreenImage(String imageUrl) {
    // Preprocess URL the same way as message display
    final processedImageUrl = imageUrl.startsWith('http') ? imageUrl : '${AppUrls.imageUrl}$imageUrl';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            // Full screen image
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                  child: Image.network(
                    processedImageUrl,
                    fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image,
                            color: Colors.white70,
                            size: 80,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _chatController.sendStoppedTypingIndicator();
    });
  }
  
  void _handleSendMessage() {
    // Send stopped typing indicator when message is sent
    _chatController.sendStoppedTypingIndicator();
    _typingTimer?.cancel();
    
    // Debug logging
    print('🚀 [CHAT VIEW] Send button pressed');
    print('📝 [CHAT VIEW] Has pending content: ${_chatController.hasPendingMessage}');
    print('💬 [CHAT VIEW] Has chat: ${_chatController.hasChat}');
    print('🆔 [CHAT VIEW] Chat ID: "${_chatController.chatId}"');
    
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
    }
    
    if (!_chatController.hasPendingMessage) {
      print('⚠️ [CHAT VIEW] Cannot send - no content to send');
      return;
    }
      
    // Send the actual message
    print('✅ [CHAT VIEW] Sending pending message...');
    _chatController.sendPendingMessage();
    _messageController.clear();
  }

  void _handleTextChanged(String text) {
    _chatController.updateDraftMessage(text);
    
    // Handle typing indicator
    if (text.isNotEmpty) {
      _chatController.sendTypingIndicator();
      _startTypingTimer();
    } else {
      _chatController.sendStoppedTypingIndicator();
    }
  }

  void _handleImageAttachment() {
    _showImageSourceDialog();
  }
  
  void _handleEmojiPicker() {
    setState(() {
      _showEmojiPicker = !_showEmojiPicker;
    });
    
    // Hide keyboard when emoji picker is shown
    if (_showEmojiPicker) {
      FocusScope.of(context).unfocus();
    }
  }
  
  void _onEmojiSelected(Emoji emoji) {
    // Add emoji to the current text
    final currentText = _messageController.text;
    final cursorPosition = _messageController.selection.baseOffset;
    
    // Insert emoji at cursor position or at the end
    final newText = cursorPosition >= 0 
        ? currentText.replaceRange(cursorPosition, cursorPosition, emoji.code)
        : currentText + emoji.code;
    
    _messageController.text = newText;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition >= 0 ? cursorPosition + emoji.code.length : newText.length)
    );
    
    // Update draft message
    _handleTextChanged(newText);
  }
  
  Widget _buildEmojiPicker() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3A59),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        children: [
          // Emoji categories
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildEmojiCategoryButton('😀', 'Smileys'),
                _buildEmojiCategoryButton('🐶', 'Animals'),
                _buildEmojiCategoryButton('🍎', 'Food'),
                _buildEmojiCategoryButton('⚽', 'Activities'),
                _buildEmojiCategoryButton('🚗', 'Travel'),
                _buildEmojiCategoryButton('💡', 'Objects'),
                _buildEmojiCategoryButton('🔣', 'Symbols'),
                _buildEmojiCategoryButton('🏁', 'Flags'),
              ],
            ),
          ),
          
          // Emoji grid - horizontally scrollable
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: (_getAllEmojis().length / 40).ceil(), // Divide into pages of 40 emojis each
              itemBuilder: (context, pageIndex) {
                final startIndex = pageIndex * 40;
                final endIndex = math.min(startIndex + 40, _getAllEmojis().length);
                final pageEmojis = _getAllEmojis().sublist(startIndex, endIndex);
                
                return Container(
                  width: MediaQuery.of(context).size.width, // Full width per page
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Disable nested scrolling
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: pageEmojis.length,
                    itemBuilder: (context, index) {
                      final emoji = pageEmojis[index];
                      return GestureDetector(
                        onTap: () => _onEmojiSelected(emoji),
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            emoji.code,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmojiCategoryButton(String emoji, String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () {
          // Scroll to category (simplified - just shows all emojis)
        },
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
  
  void _handleSendImageDirectly() {
    _showImageSourceDialog(forDirectSend: true);
  }

  void _showImageSourceDialog({bool forDirectSend = false}) {
    Get.dialog(
      AlertDialog(
        title: Text(
          forDirectSend ? 'Send Image' : 'Select Image Source',
          style: const TextStyle(color: Colors.white)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (forDirectSend) ...[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Gallery & Send', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Pick from gallery and send immediately', style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  Get.back();
                  await _chatController.pickAndSendImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera & Send', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Take photo and send immediately', style: TextStyle(color: Colors.white70)),
                onTap: () async {
                  Get.back();
                  await _chatController.takeAndSendPhoto();
                },
              ),
              const Divider(color: Colors.white30),
              ListTile(
                leading: const Icon(Icons.preview, color: Colors.orange),
                title: const Text('Preview First', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Add to message preview before sending', style: TextStyle(color: Colors.white70)),
                onTap: () {
                  Get.back();
                  _chatController.pickImageForPreview();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Gallery', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  _chatController.pickImageForPreview();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.green),
                title: const Text('Camera', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Get.back();
                  _chatController.takePhotoForPreview();
                },
              ),
            ],
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
                          Row(
                            children: [
                              Text(
                                hasChat ? 'Online' : 'Creating chat...',
                                style: TextStyle(
                                  color: hasChat ? Colors.green : Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              if (hasChat) ...[
                                const SizedBox(width: 8),
                                Obx(() {
                                  final isConnected = _chatController.isConnected.value;
                                  final connectionStatus = _chatController.connectionStatus.value;
                                  
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: isConnected ? Colors.green : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        connectionStatus,
                                        style: TextStyle(
                                          color: isConnected ? Colors.green : Colors.red,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ],
                            ],
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
            
            // Typing indicator
            Obx(() {
              if (_chatController.isParticipantTyping.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _chatController.typingStatus.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
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
                            color: Colors.white70,
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
                      final messageImages = message.images;
                      
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
                                images: messageImages,
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
                                images: messageImages,
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
            
            // Pending message preview
            Obx(() {
              if (_chatController.hasPendingContent.value) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E3A59),
                    border: Border(
                      top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text preview
                      if (_chatController.draftMessage.value.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            _chatController.draftMessage.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      
                      // Images preview
                      if (_chatController.pendingImages.isNotEmpty)
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _chatController.pendingImages.length,
                            itemBuilder: (context, index) {
                              final imagePath = _chatController.pendingImages[index];
                              return Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    // Image preview
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(imagePath),
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.broken_image,
                                              color: Colors.white54,
                                              size: 24,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    
                                    // Remove button
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: GestureDetector(
                                        onTap: () {
                                          _chatController.removePendingImage(imagePath);
                                        },
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            
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
                  // Image attachment button with long press for direct send
                  GestureDetector(
                    onLongPress: _handleSendImageDirectly,
                    child: IconButton(
                      icon: const Icon(
                        Icons.image,
                        color: Colors.white70,
                        size: 24,
                      ),
                      onPressed: _handleImageAttachment,
                      tooltip: 'Tap to preview, Long press to send directly',
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Emoji button
                  IconButton(
                    icon: Icon(
                      _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                      color: Colors.white70,
                      size: 24,
                    ),
                    onPressed: _handleEmojiPicker,
                    tooltip: 'Toggle Emoji Picker',
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
                        onChanged: _handleTextChanged,
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
            
            // Emoji picker (conditionally shown)
            if (_showEmojiPicker)
              _buildEmojiPicker(),
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
        List<String>? images,
      }) {
        final isImageMessage = messageType == 'image' || messageType == 'mixed' || messageType == 'custom';
        final hasImages = images != null && images.isNotEmpty;
        
        return Container(
          padding: (hasImages || isImageMessage) ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF5D7AFF),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display images if available
              if (hasImages) ...[
                // Show first image (can be extended to show multiple images)
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: GestureDetector(
                      onTap: () => _showFullScreenImage(images.first),
                      child: Image.network(
                        images.first.startsWith('http') ? images.first : '${AppUrls.imageUrl}${images.first}',
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.white70,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // Show image count if multiple images
                if (images.length > 1) ...[
                  const SizedBox(height: 4),
                  Text(
                    '+${images.length - 1} more image${images.length > 2 ? 's' : ''}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (message.isNotEmpty) const SizedBox(height: 8),
              ] else if (isImageMessage && message.isNotEmpty) ...[
                // Fallback for image type messages without image URLs
                Container(
                  width: 200,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
        List<String>? images,
      }) {
        final isImageMessage = messageType == 'image' || messageType == 'mixed' || messageType == 'custom';
        final hasImages = images != null && images.isNotEmpty;
        
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
                padding: (hasImages || isImageMessage) ? const EdgeInsets.all(8) : const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF3A4A6B),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display images if available
                    if (hasImages) ...[
                      // Show first image (can be extended to show multiple images)
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: GestureDetector(
                            onTap: () => _showFullScreenImage(images.first),
                            child: Image.network(
                              images.first.startsWith('http') ? images.first : '${AppUrls.imageUrl}${images.first}',
                              width: 200,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Colors.white70,
                                    size: 40,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 150,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white54),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      // Show image count if multiple images
                      if (images.length > 1) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${images.length - 1} more image${images.length > 2 ? 's' : ''}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (message.isNotEmpty) const SizedBox(height: 8),
                    ] else if (isImageMessage && message.isNotEmpty) ...[
                      // Fallback for image type messages without image URLs
                      Container(
                        width: 200,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
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