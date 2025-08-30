import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/home/widget/nav_card.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  int _currentIndex = 3; // Profile tab index

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    
    // Handle navigation based on the selected index
    if (index == 0) {
      Get.offAllNamed(AppRoutes.homeSuggestionView);
    } 
    else if (index == 1) {
      Get.offAllNamed(AppRoutes.aiAssistantView);
    }
    else if (index == 2) {
      Get.offAllNamed(AppRoutes.getMessageViewRoute());
    }
    else if (index == 3) {
      // Already on profile view
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Content
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120), // Add padding for the bottom navigation
              child: Column(
                children: [
                  // Header with title
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                    child: const Text(
                      'Profile and Setting',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  // Profile picture and details
                  _buildProfilePicture(),
                  _buildProfileDetails(),
                  
                  // Profile options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: _buildListTileOptions(),
                    ),
                  ),
                  
                  // Bottom spacing for the navigation bar
                  const SizedBox(height: 100),
                ],
              ),
            ),
            
            // Fixed Navigation Card at the bottom
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

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: 120,
            height: 120,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4A373),
                width: 2,
              ),
              image: const DecorationImage(
                image: NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '28',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        const SizedBox(height: 8),
        const Text(
          'John Doe',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF21293F), // #21293F
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFD4A373)),
          ),
          child: const Text(
            'Profile Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your profile is 95% complete!',
          style: TextStyle(
            color: Color(0xFFD4A373),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildListTileOptions() {
    return [
      _buildListTile('assets/svg/profile/setting.svg', 'Setting', () => Get.toNamed(AppRoutes.accountSettingView)),
      _buildListTile('assets/svg/profile/location.svg', 'Location', () {}),
      _buildListTile('assets/svg/profile/terms.svg', 'Terms and Conditions', () {}),
      _buildListTile('assets/svg/profile/informations.svg', 'About', () {}),
      _buildListTile('assets/svg/profile/faq.svg', 'Help and Support', () {}),
      _buildListTile('assets/svg/profile/log out.svg', 'Logout', () {}),
    ];
  }

  Widget _buildListTile(String iconPath, String title, VoidCallback onTap) {
    return Column(
      children: [
        // Spacer for top space before the divider
        const SizedBox(height: 10),

        // Divider before each ListTile
        const Divider(height: 1, color: Color(0xFF755A3F)),

        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Center the content horizontally
              crossAxisAlignment: CrossAxisAlignment.center, // Center the content vertically
              children: [
                SvgPicture.asset(iconPath, width: 24, height: 24, colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                const SizedBox(width: 20),
                Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontFamily: 'PlayfairDisplay', fontSize: 18, fontWeight: FontWeight.w400))),
              ],
            ),
          ),
        ),
        
        // Spacer for bottom space after the content
        const SizedBox(height: 10),
      ],
    );
  }
}
