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
    final isSmallScreen = size.width < 375;
    final buttonBottomPadding = isSmallScreen ? 20.0 : 40.0;
    final pageIndicatorBottom = isSmallScreen ? 100.0 : 120.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF21293F),
      body: Container(
        width: size.width,
        height: size.height,
        color: const Color(0xFF21293F),
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
              bottom: pageIndicatorBottom,
              left: 0, 
              right: 0,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(onboardingPages.length, (index) {
                    final isActive = _currentPage == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isActive ? size.width * 0.08 : size.width * 0.04,
                      height: size.height * 0.01,
                      margin: EdgeInsets.symmetric(horizontal: size.width * 0.015),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: isActive
                            ? Colors.white
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
                bottom: buttonBottomPadding,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Skip button
                      TextButton(
                        onPressed: () {
                          Get.offAllNamed(AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE2DFDC),
                          textStyle: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.none,
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
                        size: size.width * 0.16,
                        iconSize: size.width * 0.08,
                      ),
                    ],
                  ),
                ),
              )
            else
              Positioned(
                bottom: buttonBottomPadding,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
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
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 375;
    final titleStyle = TextStyle(
      fontSize: isSmallScreen ? 24 : 28,
      fontFamily: 'PlayfairDisplay',
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1.33,
      letterSpacing: 0,
    );
    
    final descriptionStyle = TextStyle(
      fontSize: isSmallScreen ? 14 : 16,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w500,
      color: Colors.white,
      height: 1.5,
    );

    return Stack(
      children: [
        // Background Image with ColorFilter
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, isSmallScreen ? -30 : -60),
            child: Image.asset(
              image,
              width: double.infinity,
              height: size.height * (isSmallScreen ? 1.1 : 1.2),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              color: Colors.white.withOpacity(0.2),
              colorBlendMode: BlendMode.overlay,
            ),
          ),
        ),
        
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.5, 0.8],
              colors: [
                Colors.transparent,
                const Color(0xFF2E3A59).withOpacity(0.2),
                const Color(0xFF2E3A59),
              ],
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(size.width * 0.06),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 4),
                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle,
                ),
                SizedBox(height: size.height * 0.02),
                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: descriptionStyle,
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}