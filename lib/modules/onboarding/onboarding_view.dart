  import 'package:flutter/material.dart';
  import 'package:get/get.dart';
  import 'onboarding_controller.dart';
  import 'widget_button.dart';

  class OnboardingView extends GetView<OnboardingController> {
    const OnboardingView({super.key});

    @override
    Widget build(BuildContext context) {
      final List<Map<String, String>> onboardingPages = [
        {
          'image': 'assets/images/ob1.jpg',
          'title': 'Welcome to\nKindred',
          'description': 'Find your perfect match and make meaningful connections with people who share your interests and values.',
        },
        {
          'image': 'assets/images/ob2.jpg',
          'title': 'Discover\nNew People',
          'description': 'Swipe and connect with amazing people in your area who share your passions and interests.',
        },
        {
          'image': 'assets/images/ob3.jpg',
          'title': 'Start\nChatting',
          'description': 'Build meaningful relationships through real conversations and shared experiences.',
        },
      ];

      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // PageView for onboarding slides
              PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: onboardingPages.length,
                itemBuilder: (context, index) {
                  final page = onboardingPages[index];
                  return _buildPage(
                    image: page['image']!,
                    title: page['title']!,
                    description: page['description']!,
                  );
                },
              ),
              
              // Bottom controls
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      // Page indicators
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          onboardingPages.length,
                          (index) => Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: controller.currentPage.value == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      )),
                      
                      const SizedBox(height: 30),
                      
                      // Next/Get Started button
                      Obx(() => OnboardingButton(
                        text: controller.currentPage.value == onboardingPages.length - 1
                            ? 'GET STARTED'
                            : 'NEXT',
                        onPressed: controller.nextPage,
                      )),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _buildPage({
    required String image,
    required String title,
    required String description,
  }) {
    return Stack(
      children: [
        // Background Image with ColorFilter to make it brighter
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(image),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.white.withValues(alpha: 0.2), // Increased opacity for better visibility
                BlendMode.overlay, // Changed to overlay for better contrast
              ),
            ),
          ),
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.5, 0.8],  // Start fade lower down the screen
              colors: [
                Colors.transparent, // Fully transparent at top
                Color(0xFF2E3A59).withOpacity(0.2),  // Start color transition lower
                Color(0xFF2E3A59),  // Full color at bottom
              ],
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                description,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 100), // Space for bottom controls
            ],
          ),
        ),
      ],
    );
  }
}