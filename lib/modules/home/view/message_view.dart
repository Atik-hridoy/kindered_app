import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/message_controller.dart';
import '../models/message_view_getChat_list.dart';
import '../widget/nav_card.dart';

class MessageView extends GetView<MessageController> {
  const MessageView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Stack(
          children: [
            
            Column(
              children: [
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      
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
                              child: Obx(() {
                                // Check if controller is disposed
                                if (controller.isDisposed.value) {
                                  return const SizedBox();
                                }
                                return TextField(
                                  controller: controller.searchController,
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                  decoration: const InputDecoration(
                                    hintText: 'Search messages...',
                                    hintStyle: TextStyle(color: Colors.white54),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                                  ),
                                );
                              }),
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
                
                
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return ListView.builder(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 8,
                          bottom: 80,
                        ),
                        itemCount: 6, // Show 6 skeleton items
                        itemBuilder: (context, index) {
                          return _buildChatSkeleton();
                        },
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white54,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No conversations yet',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start a chat from the Home suggestions',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => controller.handleNavigation(0), // Navigate to Home tab
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4A373),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: const Text('Find People to Chat'),
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
                        bottom: 80, 
                      ),
                      itemCount: controller.filteredChatList.length,
                      itemBuilder: (context, index) {
                        final chat = controller.filteredChatList[index];
                        return _buildChatItem(
                          chat: chat,
                          profileImage: controller.getProfileImage(chat),
                          name: chat.participantName,
                          message: controller.getLastMessageText(chat),
                          time: controller.formatTime(chat.updatedAt),
                          unreadCount: controller.getUnreadCountText(chat),
                          hasUnread: controller.hasUnreadMessages(chat),
                          status: controller.getChatStatus(chat),
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
            
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: NavCard(
                currentIndex: 2, 
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
    required Chat chat,
    required String profileImage,
    required String name,
    required String message,
    required String time,
    required String unreadCount,
    required bool hasUnread,
    required String status,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () => controller.navigateToChat(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile image with online status
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: DecorationImage(
                      image: NetworkImage(profileImage),
                      fit: BoxFit.cover,
                    ),
                    border: hasUnread 
                      ? Border.all(color: const Color(0xFFD4A373), width: 2)
                      : null,
                  ),
                ),
                // Online status indicator (can be enhanced with real status)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      border: Border.all(color: const Color(0xFF2E3A59), width: 2),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w600,
                                  fontFamily: 'PlayfairDisplay',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (status.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Text(
                                status,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Text(
                        time,
                        style: TextStyle(
                          color: hasUnread ? const Color(0xFFD4A373) : Colors.white.withValues(alpha: .7),
                          fontSize: 13,
                          fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
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
                            color: hasUnread ? Colors.white : Colors.white.withValues(alpha: .8),
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (unreadCount.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4A373),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            unreadCount,
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

  /// Build a smooth skeleton loader for chat items
  Widget _buildChatSkeleton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: -1.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile image skeleton with shimmer
              _buildShimmerContainer(
                width: 60,
                height: 60,
                borderRadius: 25,
                shimmerValue: value,
              ),
              
              const SizedBox(width: 16),
              
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Name skeleton
                        _buildShimmerContainer(
                          width: 120,
                          height: 20,
                          borderRadius: 4,
                          shimmerValue: value,
                        ),
                        // Time skeleton
                        _buildShimmerContainer(
                          width: 50,
                          height: 16,
                          borderRadius: 4,
                          shimmerValue: value,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Message skeleton
                        Expanded(
                          child: _buildShimmerContainer(
                            height: 16,
                            borderRadius: 4,
                            shimmerValue: value,
                          ),
                        ),
                        // Unread count skeleton
                        _buildShimmerContainer(
                          width: 24,
                          height: 24,
                          borderRadius: 12,
                          shimmerValue: value,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a single shimmer container with gradient animation
  Widget _buildShimmerContainer({
    required double shimmerValue,
    double? width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.05),
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
          stops: [
            0.0,
            0.5 + (shimmerValue * 0.5),
            1.0,
          ],
        ),
      ),
    );
  }
}