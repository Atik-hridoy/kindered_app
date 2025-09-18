import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widget/nav_card.dart';
import '../controller/ai_assistent_controller.dart';
import '../../../config/app_routes.dart';

class AiAssistantView extends GetView<AiAssistentController> {
  const AiAssistantView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(AiAssistentController());
    
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Fixed Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: const Color(0xFF2E3A59),
                  child: _buildHeader(),
                ),
                
                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100), // Space for input and navigation
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Dynamic messages from controller
                          Obx(
                            () => Column(
                              children: controller.messages.map((message) {
                                return _buildMessageBubble(
                                  text: message['text'],
                                  isMe: message['isMe'],
                                  timestamp: message['timestamp'],
                                );
                              }).toList(),
                            ),
                          ),
                          
                          // Show loading indicator
                          Obx(
                            () => controller.isLoading.value
                                ? const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          
                          const SizedBox(height: 24),
                          _buildMatchSuggestionCard(),
                          const SizedBox(height: 32),
                          _buildQuickQuestions(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
                // Message input fixed above navigation
                Padding(
                  padding: const EdgeInsets.only(bottom: 100, left: 20, right: 20, top: 12),
                  child: _buildMessageInput(),
                ),
              ],
            ),
            Positioned(
              left: 16, right: 16, bottom: 20,
              child: NavCard(
                currentIndex: 1,
                onTap: (index) {
                  switch (index) {
                    case 0: Get.offAllNamed(AppRoutes.homeSuggestionView); break;
                    case 1: break; // Current view
                    case 2: Get.offAllNamed(AppRoutes.messageView); break; // Chat tab
                    case 3: Get.offAllNamed(AppRoutes.profileView); break;
                  }
                },
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

  Widget _buildHeader() {
    return Row(
      children: [
        _buildIcon(),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Assistant', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            Text('Online', style: TextStyle(color: Colors.green, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF21293F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/svg/ai.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String text,
    required bool isMe,
    required DateTime timestamp,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: EdgeInsets.only(
          left: isMe ? 100 : 4,
          right: isMe ? 4 : 100,
          top: 4,
          bottom: 4,
        ),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFD4A574) : const Color(0xFF3A4A6B),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe ? const Color(0xFF2E3A59) : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              controller.formatTime(timestamp),
              style: TextStyle(
                color: isMe ? const Color(0xFF2E3A59).withOpacity(0.7) : Colors.white54,
                fontSize: 10,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMatchSuggestionCard() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.only(left: 16, right: 100, top: 4, bottom: 4),
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFD4A373),
            borderRadius: BorderRadius.circular(20),
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(Get.context!).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'We found someone who matches with you',
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildProfileImage(),
              const SizedBox(height: 16),
              const SizedBox(height: 8),
              const Text('Kelvin, 28', style: TextStyle(color: Color(0xFF2E3A59), fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Love cooking, enjoy new things, values kindness', 
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 12)
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
              const SizedBox(height: 12),
              const Text(
                'If pass, your next curated match will arrive soon', 
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 10, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Container(
      width: 120, height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        _buildActionButton('Discover', const Color(0xFF2E3A59), Colors.white),
        const SizedBox(width: 12),
        _buildActionButton('Pass', Colors.transparent, const Color(0xFF2E3A59), borderColor: const Color(0xFF2E3A59)),
      ],
    );
  }

  Widget _buildActionButton(String text, Color backgroundColor, Color textColor, {Color? borderColor}) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
        ),
        child: Center(
          child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick question:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        _buildQuickQuestionButton('Give me a romantic date idea!'),
        _buildQuickQuestionButton("What's my love compatibility?"),
      ],
    );
  }

  Widget _buildQuickQuestionButton(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          // Set the text in the controller and send message
          controller.messageController.text = text;
          controller.sendMessage();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3A4A6B),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF3A4A6B), borderRadius: BorderRadius.circular(25)),
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller.messageController,
              focusNode: controller.messageFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Ask about your love journey...',
                hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => controller.sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => GestureDetector(
              onTap: controller.isSendButtonEnabled.value ? () => controller.sendMessage() : null,
              child: Icon(
                Icons.send,
                color: controller.isSendButtonEnabled.value ? Colors.white : Colors.white54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
