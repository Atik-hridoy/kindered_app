import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/modules/home/widget/nav_card.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/profile_view_controller.dart';
import 'package:kindered_app/local/storage_service.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileViewController controller = Get.put(ProfileViewController());
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh profile data when the view becomes active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshProfileData();
    });
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
            
            // Loading overlay with skeletonizer
            Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Skeletonizer(
                      enabled: true,
                      effect: ShimmerEffect(
                        baseColor: const Color(0xFF4A5568),
                        highlightColor: const Color(0xFF718096),
                      ),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E3A59),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: _buildSkeletonProfile(),
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Obx(() {
      final profilePhoto = controller.profilePhoto;
      final age = controller.age;
      
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
                image: DecorationImage(
                  image: NetworkImage(profilePhoto),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (age.isNotEmpty)
              Positioned(
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    age,
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
      final name = controller.name;
      final profileCompletionText = controller.profileCompletionText;
      
      return Column(
        children: [
          const SizedBox(height: 8),
          Text(
            name,
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
            profileCompletionText,
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
      _buildListTile('assets/svg/profile/setting.svg', 'Setting', () => Get.toNamed(AppRoutes.accountSettingView)),
      _buildListTile('assets/svg/profile/location.svg', 'Location', () => Get.toNamed(AppRoutes.newLocationView)),
      _buildListTile('assets/svg/profile/terms.svg', 'Terms and Conditions', 
          () => Get.toNamed(AppRoutes.termsAndConditions)),
      _buildListTile('assets/svg/profile/informations.svg', 'About', () => Get.toNamed(AppRoutes.aboutUsView)),
      _buildListTile('assets/svg/profile/faq.svg', 'Help and Support', () => Get.toNamed(AppRoutes.helpSupportView)),
      _buildListTile('assets/svg/profile/log out.svg', 'Logout', () => _showLogoutConfirmation()),
    ];
  }

  void _showLogoutConfirmation() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Logout Confirmation',
          style: TextStyle(
            color: Color(0xFFD29A67),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFF2E3A59),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Clear all saved authentication data
              await LocalStorage.clearAll();
              
              // Navigate to onboarding
              Get.offAllNamed(AppRoutes.onboarding);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD29A67),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Yes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: Get.back,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21293F),
              foregroundColor: Colors.white,
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFFD29A67), width: 1),
              ),
            ),
            child: const Text(
              'No',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
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

  /// Build skeleton profile that matches the actual profile structure
  Widget _buildSkeletonProfile() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Skeleton profile picture
        Bone.circle(
          size: 120,
        ),
        const SizedBox(height: 20),
        
        // Skeleton name
        Bone(
          height: 24,
          width: 150,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 16),
        
        // Skeleton profile details button
        Bone(
          height: 40,
          width: 180,
          borderRadius: BorderRadius.circular(14),
        ),
        const SizedBox(height: 12),
        
        // Skeleton completion text
        Bone(
          height: 16,
          width: 120,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 32),
        
        // Skeleton list tiles
        ...List.generate(6, (index) => _buildSkeletonListTile()),
      ],
    );
  }

  /// Build skeleton list tile that matches the actual list tile structure
  Widget _buildSkeletonListTile() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Divider(height: 1, color: Color(0xFF755A3F)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Bone.square(
                size: 24,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Bone(
                  height: 18,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}