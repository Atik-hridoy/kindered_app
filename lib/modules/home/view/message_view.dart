import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/message_controller.dart';  // Import your controller
import '../widget/nav_card.dart';  // Your navigation widget

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Header with title and search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlayfairDisplay',
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Search bar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF171E38),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: Colors.white54,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: controller.searchController,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                decoration: const InputDecoration(
                                  hintText: 'Search messages...',
                                  hintStyle: TextStyle(color: Colors.white54),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            Obx(() => controller.searchQuery.value.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                                    onPressed: () {
                                      controller.clearSearch();
                                      FocusScope.of(context).unfocus();
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  )
                                : const SizedBox.shrink()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Chat list
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Loading messages...',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (controller.errorMessage.value.isNotEmpty) {
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
                              controller.errorMessage.value,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => controller.refreshChatList(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A373),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    if (controller.filteredChatList.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white54,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No messages yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 8,
                        bottom: 100, // Add bottom padding to prevent content from being hidden behind the nav
                      ),
                      itemCount: controller.filteredChatList.length,
                      itemBuilder: (context, index) {
                        final chat = controller.filteredChatList[index];
                        return _buildChatItem(
                          profileImage: controller.getProfileImage(chat),
                          name: chat.participantName,
                          message: controller.getLastMessageText(chat),
                          time: controller.formatTime(chat.updatedAt),
                          unreadCount: chat.unreadCount,
                          onTap: () => controller.navigateToChat(
                            chatId: chat.id,
                            participantName: chat.participantName,
                            participantId: chat.participantId,
                          ),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
            // Bottom Navigation - Positioned at the bottom of the screen
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: NavCard(
                currentIndex: 2, // Messages tab is active (0-based index)
                onTap: controller.handleNavigation,
                iconPaths: const [
                  'assets/svg/explore.svg',
                  'assets/svg/ai.svg',
                  'assets/svg/Chat.svg',
                  'assets/svg/menu Frame.svg',
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a chat item widget
  Widget _buildChatItem({
    required String profileImage,
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => controller.navigateToChat(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: NetworkImage(profileImage),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Chat details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'PlayfairDisplay',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  

                  const SizedBox(height: 6),
                  

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          message,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF171E38),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
