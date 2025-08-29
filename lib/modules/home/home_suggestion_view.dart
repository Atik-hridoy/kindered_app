import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kindered_app/modules/home/widget/custom_photo_card.dart';
import 'package:kindered_app/modules/home/widget/nav_card.dart'; // Add this import

class HomeSuggestionView extends StatefulWidget {  // Changed to StatefulWidget
  const HomeSuggestionView({super.key});

  @override
  State<HomeSuggestionView> createState() => _HomeSuggestionViewState();
}

class _HomeSuggestionViewState extends State<HomeSuggestionView> {
  int _currentIndex = 0;  // Add this line to track the selected tab

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
                    child: CustomPhotoCard(
                      imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1000&q=80',
                      matchPercentage: '92%',
                      name: 'Kelvin',
                      age: '23',
                      location: '5 km away',
                      onChatPressed: () {
                        // Handle chat action
                      },
                      onSharePressed: () {
                        // Handle share action
                      },
                    ),
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
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  // Add navigation logic here based on index
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}