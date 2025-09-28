import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widget/nav_card.dart';
import '../controller/ai_assistent_controller.dart';
import '../models/ai_assistent_get_model.dart';
import '../../../config/app_routes.dart';
import '../../../core/app_urls.dart';

class AiAssistantView extends StatefulWidget {
  const AiAssistantView({super.key});

  @override
  State<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends State<AiAssistantView> {
  late final AiAssistentController controller;
  
  // Local FocusNode to prevent disposal issues
  final FocusNode _messageFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize controller properly
    if (Get.isRegistered<AiAssistentController>()) {
      controller = Get.find<AiAssistentController>();
    } else {
      controller = Get.put<AiAssistentController>(AiAssistentController());
    }
  }

  @override
  void dispose() {
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    padding: const EdgeInsets.only(bottom: 180), // Increased space for input and navigation
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Prevent overflow
                        children: [
                          // Dynamic messages from controller
                          Obx(
                            () => Column(
                              mainAxisSize: MainAxisSize.min, // Prevent overflow
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
              ],
            ),
            // Message input positioned above navigation
            Positioned(
              left: 20, right: 20, bottom: 90,
              child: _buildMessageInput(),
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
    return Obx(() {
      final matchmakingData = controller.matchmakingData.value;
      final isLoading = controller.isLoading.value;
      final errorMessage = controller.errorMessage.value;
      
      if (isLoading) {
        return _buildLoadingCard();
      }
      
      if (errorMessage.isNotEmpty) {
        return _buildErrorCard(errorMessage);
      }
      
      // Get match data from the latest AI message
      MatchData? matchData;
      MatchUser? user;
      
      // Find the latest AI message with match data
      for (int i = controller.messages.length - 1; i >= 0; i--) {
        final message = controller.messages[i];
        if (!message['isMe'] && message['matchData'] != null) {
          matchData = message['matchData'] as MatchData?;
          break;
        }
      }
      
      // Prioritize currentMatch from matchmakingData over message-based match data
      CurrentMatch? currentMatch;
      if (matchmakingData?.data?.currentMatch != null) {
        currentMatch = matchmakingData!.data!.currentMatch;
        user = currentMatch.user;
      } else if (matchData != null) {
        // Fallback: Create a MatchUser from the match data in messages
        user = MatchUser(
          id: matchData.userId,
          firstName: matchData.userFirstName ?? '',
          lastName: matchData.userLastName ?? '',
          role: 'USER',
          email: '',
          age: matchData.userAge,
          gender: matchData.userGender ?? '',
          bodyImage: '',
          headShotImage: matchData.userImage.isNotEmpty ? matchData.userImage.first : '',
          personalityImage: '',
          image: matchData.userImage,
          likeToMeet: [],
          interests: Interests.fromJson({}),
          personalTraitsInspire: [],
          religion: '',
          zodiacSign: '',
          lifestyle: Lifestyle.fromJson({}),
          habits: Habits.fromJson({}),
          address: '',
          status: 'active',
          isVerified: false,
          profileCompletionPercentage: 0,
          isDeleted: false,
        );
      }
      
      if (user == null) {
        return _buildNoMatchCard();
      }
      
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
                Text(
                  'We found someone who matches with you',
                  style: const TextStyle(color: Color(0xFF2E3A59), fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildProfileImage(user.headShotImage, user),
                const SizedBox(height: 16),
                const SizedBox(height: 8),
                Text(
                  '${user.firstName}, ${user.age}', 
                  style: const TextStyle(color: Color(0xFF2E3A59), fontSize: 18, fontWeight: FontWeight.w700)
                ),
                const SizedBox(height: 4),
                Text(
                  currentMatch != null ? _buildUserDescription(currentMatch) : 'Great match based on your preferences', 
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF2E3A59), fontSize: 12)
                ),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 12),
                Text(
                  (matchmakingData?.data?.hasMoreMatches ?? false) 
                      ? 'If pass, your next curated match will arrive soon'
                      : 'This is your last curated match for today', 
                  style: const TextStyle(color: Color(0xFF2E3A59), fontSize: 10, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProfileImage([String? imageUrl, MatchUser? user]) {
    final defaultImage = 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80';
    
    // Debug: Print the image URL to see what we're getting
    print('DEBUG: Image URL received: $imageUrl');
    print('DEBUG: Image URL is null: ${imageUrl == null}');
    print('DEBUG: Image URL is empty: ${imageUrl?.isEmpty ?? true}');
    
    // Try to get image from different possible sources
    String? finalImageUrl;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      finalImageUrl = imageUrl;
    } else if (user != null) {
      // Try alternative image fields from the user object
      if (user.image.isNotEmpty) {
        finalImageUrl = user.image.first;
        print('DEBUG: Using first image from user.image list: $finalImageUrl');
      } else if (user.bodyImage.isNotEmpty) {
        finalImageUrl = user.bodyImage;
        print('DEBUG: Using bodyImage: $finalImageUrl');
      } else if (user.personalityImage.isNotEmpty) {
        finalImageUrl = user.personalityImage;
        print('DEBUG: Using personalityImage: $finalImageUrl');
      }
    }
    
    // If the image URL is relative (starts with /), prepend the base URL
    if (finalImageUrl != null && finalImageUrl.isNotEmpty && finalImageUrl.startsWith('/')) {
      finalImageUrl = '${AppUrls.imageUrl}$finalImageUrl';
      print('DEBUG: Converted relative URL to absolute: $finalImageUrl');
    }
    
    final imageProvider = (finalImageUrl != null && finalImageUrl.isNotEmpty) 
        ? NetworkImage(finalImageUrl) 
        : NetworkImage(defaultImage) as ImageProvider;
    
    print('DEBUG: Final image URL being used: ${finalImageUrl ?? defaultImage}');
    
    return Container(
      width: 120, height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final AiAssistentController controller = Get.find<AiAssistentController>();
    
    return Row(
      children: [
        _buildActionButton(
          'Discover', 
          const Color(0xFF2E3A59), 
          Colors.white,
          onPressed: () => controller.discoverMatch(),
        ),
        const SizedBox(width: 12),
        _buildActionButton(
          'Pass', 
          Colors.transparent, 
          const Color(0xFF2E3A59),
          borderColor: const Color(0xFF2E3A59),
          onPressed: () => controller.passMatch(),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color backgroundColor, Color textColor, {Color? borderColor, VoidCallback? onPressed}) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(22),
            border: borderColor != null ? Border.all(color: borderColor, width: 1) : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 0,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(text, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Quick question:', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
              Obx(
                () => controller.isQuickQuestionsLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A574)),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => controller.refreshQuickQuestions(),
                        child: const Icon(
                          Icons.refresh,
                          color: Color(0xFFD4A574),
                          size: 16,
                        ),
                      ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Show error message if exists
        Obx(
          () => controller.quickQuestionsError.value.isNotEmpty
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.quickQuestionsError.value,
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.clearQuickQuestionsError(),
                        child: const Icon(Icons.close, color: Colors.red, size: 16),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
        
        // Show quick questions
        Obx(
          () => Column(
            children: controller.quickQuestions.map((question) {
              return _buildQuickQuestionButton(question);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickQuestionButton(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          // Process the quick question using the dedicated method
          controller.processQuickQuestion(text);
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
              focusNode: _messageFocusNode,
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

  // Helper methods for dynamic match suggestion card
  Widget _buildLoadingCard() {
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Finding your perfect match...',
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E3A59)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String errorMessage) {
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
                'Oops! Something went wrong',
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                errorMessage,
                style: const TextStyle(color: Color(0xFF2E3A59), fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => controller.refreshMatchmakingData(),
                child: const Text(
                  'Try Again',
                  style: TextStyle(color: Color(0xFF2E3A59), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoMatchCard() {
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'No matches available right now',
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 16, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              Text(
                'We\'re working on finding your perfect match. Check back soon!',
                style: TextStyle(color: Color(0xFF2E3A59), fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildUserDescription(CurrentMatch currentMatch) {
    final user = currentMatch.user;
    final interests = currentMatch.commonInterests;
    final reasons = currentMatch.reasons;
    
    List<String> descriptionParts = [];
    
    // Add interests if available
    if (interests.isNotEmpty) {
      final interestText = interests.take(3).join(', ');
      descriptionParts.add('Loves $interestText');
    }
    
    // Add match reasons if available
    if (reasons.isNotEmpty) {
      descriptionParts.add(reasons.first);
    }
    
    // Add personality traits if available
    if (user.personalTraitsInspire.isNotEmpty) {
      final traits = user.personalTraitsInspire.take(2).join(', ');
      descriptionParts.add('Values $traits');
    }
    
    // If no description parts available, use a generic message
    if (descriptionParts.isEmpty) {
      return 'Great match based on your preferences';
    }
    
    return descriptionParts.join(', ');
  }
}
