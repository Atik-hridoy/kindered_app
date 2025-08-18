import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/onboarding/widget_button.dart';
import '../../config/app_routes.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  late final PageController _pageController;
  int _currentPage = 0;

  final List<Map<String, String>> onboardingPages = const [
    {
      'image': 'assets/images/ob1.jpg',
      'title': 'More than dating Discover yourself',
      'description': 'Discover deeper compatibility through values, emotions, and style',
    },
    {
      'image': 'assets/images/ob2.jpg',
      'title': 'Meet Your Ai Companion on this Journey',
      'description': 'Powered by deep AI profiling and emotional intelligence',
    },
    {
      'image': 'assets/images/ob3.jpg',
      'title': 'Where Chemistry Meets Compatibility',
      'description': 'Find partners who align with your heart, mind, and vibe',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Stack(
          children: [
            // PageView for onboarding slides
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
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

            // Page Indicator
            Positioned(
              bottom: 120,  // Position above the buttons
              left: 0, 
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingPages.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? 24 : 10,
                      height: 10,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }),
                ),
              ),
            ),

            // Bottom Buttons
            if (_currentPage < onboardingPages.length - 1)
              Positioned(
                bottom: 40,  // Position from bottom of screen
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB0AEAC),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        ),
                        child: const Text('Skip'),
                      ),
                      
                      // Next button
                      CircularArrowButton(
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        backgroundColor: const Color(0xFF21293F),
                        size: 64,
                        iconSize: 34,
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OnboardingButton(
                    text: 'Begin your Journey',
                    onPressed: () {
                      Get.offAllNamed(AppRoutes.login);
                    },
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex:4), // Reduced space above title
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 36,
                  fontFamily: 'PlayfairDisplay',
                  fontWeight: FontWeight.w600, // SemiBold weight
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                  

                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 1),
              
            ],
          ),
        ),
      ],
    );
  }
}