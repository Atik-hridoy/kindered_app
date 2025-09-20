import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/profile_view_controller.dart';

class ProfileView extends StatelessWidget {
  final ProfileViewController controller = Get.put(ProfileViewController());

  ProfileView({Key? key}) : super(key: key);

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
                currentIndex: 3, // Profile tab index
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

  void _onNavItemTapped(int index) {
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
      // Already on profile view - refresh data
      controller.refreshProfilePhoto();
    }
  }

  Widget _buildProfilePicture() {
    return Obx(() {
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
                image: controller.profilePhoto.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(controller.profilePhoto),
                        fit: BoxFit.cover,
                      )
                    : const DecorationImage(
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
                child: Text(
                  controller.age,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildProfileDetails() {
    return Obx(() {
      return Column(
        children: [
          const SizedBox(height: 8),
          Text(
            controller.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'PlayfairDisplay',
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.editProfile),
            child: Container(
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
          ),
          const SizedBox(height: 8),
          Text(
            controller.profileCompletionText,
            style: const TextStyle(
              color: Color(0xFFD4A373),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    });
  }

  List<Widget> _buildListTileOptions() {
    return [
      _buildListTile('assets/svg/profile/setting.svg', 'Edit Profile', () => Get.toNamed(AppRoutes.editProfile)),
      _buildListTile('assets/svg/profile/setting.svg', 'Setting', () => Get.toNamed(AppRoutes.accountSettingView)),
      _buildListTile('assets/svg/profile/location.svg', 'Location', () => Get.toNamed(AppRoutes.newLocationView)),
      _buildListTile('assets/svg/profile/terms.svg', 'Terms and Conditions', 
          () => Get.toNamed(AppRoutes.termsAndConditions)),
      _buildListTile('assets/svg/profile/informations.svg', 'About', () => Get.toNamed(AppRoutes.aboutUsView)),
      _buildListTile('assets/svg/profile/faq.svg', 'Help and Support', () => Get.toNamed(AppRoutes.helpSupportView)),
      _buildListTile('assets/svg/profile/log out.svg', 'Logout', () => _showLogoutDialog()),
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

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement logout logic
              Get.offAllNamed(AppRoutes.login);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class NavCard extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<String> iconPaths;
  final List<String> labels;

  const NavCard({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.iconPaths,
    required this.labels,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF21293F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4A373),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(4, (index) {
          final isSelected = index == currentIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  iconPaths[index],
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    isSelected ? const Color(0xFFD4A373) : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                if (labels[index].isNotEmpty)
                  Text(
                    labels[index],
                    style: TextStyle(
                      color: isSelected ? const Color(0xFFD4A373) : Colors.white,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}