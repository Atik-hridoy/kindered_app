import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/home/controller/home_suggestion_controller.dart';
import 'package:kindered_app/modules/home/widget/custom_photo_card.dart';
import 'package:kindered_app/modules/home/widget/nav_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

class HomeSuggestionView extends StatefulWidget { 
  const HomeSuggestionView({super.key});

  @override
  State<HomeSuggestionView> createState() => _HomeSuggestionViewState();
}

class _HomeSuggestionViewState extends State<HomeSuggestionView> {
  final HomeSuggestionController _controller = Get.put(HomeSuggestionController());
  int _currentIndex = 0;  // Add this line to track the selected tab

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Handle navigation based on the selected index
    switch (index) {
      case 1: // AI Assistant tab
        Get.toNamed(AppRoutes.aiAssistantView);
        break;
      case 2: // Chat tab
        Get.toNamed(AppRoutes.messageView);
        break;
      case 3: // Profile tab
        Get.toNamed(AppRoutes.profileView);
        break;
      // Other cases can be added here
    }
  }

  /// Build skeleton card that matches CustomPhotoCard structure
  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Image Skeleton
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[800],
            ),
            
            // Gradient Overlay Skeleton
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
            
            // Match Percentage Tag Skeleton
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3748).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Bone.text(
                  words: 2,
                  fontSize: 12,
                ),
              ),
            ),
            
            // Right Side Actions Skeleton
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  
                  // Chat Button Skeleton
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3A59),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Bone.icon(
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Share Button Skeleton
                  Container(
                    width: 50,
                    height: 50,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E3A59),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Bone.icon(
                      size: 24,
                    ),
                  ),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
            
            // Bottom Profile Info Skeleton
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Bone.text(
                          words: 1,
                          fontSize: 32,
                        ),
                        const SizedBox(width: 4),
                        const Bone.text(
                          words: 1,
                          fontSize: 32,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Bone.icon(
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        const Bone.text(
                          words: 3,
                          fontSize: 14,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Top spacing for logo
                  const SizedBox(height: 60),
                  
                  // Photo Card
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7, // 60% of screen height
                    child: Obx(() {
                      if (_controller.isLoading.value) {
                        return Skeletonizer(
                          enabled: true,
                          effect: const ShimmerEffect(
                            baseColor: Color(0xFF3A4556),
                            highlightColor: Color(0xFF4A5568),
                          ),
                          child: _buildSkeletonCard(),
                        );
                      }
                      
                      if (_controller.errorMessage.value.isNotEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Color(0xFFD4A373),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _controller.errorMessage.value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _controller.refreshCurrentMatch(),
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
                      
                      if (!_controller.hasSuggestion) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Color(0xFFD4A373),
                                size: 48,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No suggestions available',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      // Log what data is being displayed
                      final displayedImageUrl = _controller.getValidImageUrl();
                      AppLogger.info('=== HOME SUGGESTION VIEW DATA ===');
                      AppLogger.info('Displaying Image URL: $displayedImageUrl');
                      AppLogger.info('Original Body Image: ${_controller.bodyImage}');
                      AppLogger.info('Original Primary Image: ${_controller.primaryImage}');
                      AppLogger.info('Original Image URL: ${_controller.imageUrl}');
                      AppLogger.info('User Images List: ${_controller.userImages}');
                      AppLogger.info('Match Percentage: ${_controller.matchPercentage}');
                      AppLogger.info('Name: ${_controller.name}');
                      AppLogger.info('Age: ${_controller.age}');
                      AppLogger.info('Location: ${_controller.location}');
                      AppLogger.info('Full Name: ${_controller.fullName}');
                      AppLogger.info('Bio: ${_controller.bio}');
                      AppLogger.info('User Age: ${_controller.userAge}');
                      AppLogger.info('Gender: ${_controller.gender}');
                      AppLogger.info('Has Comprehensive Data: ${_controller.hasComprehensiveData}');
                      AppLogger.info('Has Suggestion: ${_controller.hasSuggestion}');
                      AppLogger.info('===================================');
                      
                      return CustomPhotoCard(
                        imageUrl: displayedImageUrl,
                        matchPercentage: _controller.matchPercentage,
                        name: _controller.name,
                        age: _controller.age,
                        location: _controller.location.isNotEmpty ? _controller.location : 'Unknown location',
                        onChatPressed: () {
                          _controller.navigateToChat();
                        },
                        onSharePressed: () {
                          Get.toNamed(AppRoutes.displayProfile);
                        },
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
            
            // Kindred Logo positioned absolutely at the top
            Positioned(
              top: 20,
              left: 20,
              child: SvgPicture.asset(
                'assets/svg/Kindred.svg',
                width: 24,
                height: 24,
              ),
            ),

            // Navigation Card
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: NavCard(
                currentIndex: _currentIndex,
                onTap: _onNavItemTapped,
                iconPaths: const [
                  'assets/svg/explore.svg',
                  'assets/svg/ai.svg',
                  'assets/svg/Chat.svg',
                  'assets/svg/menu Frame.svg',
                ],
                labels: const ['', '', '', ''], 
              ),
            ),
          ],
        ),
      ),
    );
  }
}