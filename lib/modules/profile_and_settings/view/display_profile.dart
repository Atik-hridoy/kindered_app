import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import '../controller/display_profile_controller.dart';

class DisplayProfileView extends GetView<DisplayProfileController> {
  const DisplayProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller
    Get.put(DisplayProfileController());
    
    return Scaffold(
      backgroundColor: const Color(0xFF2E3A59),
      body: SafeArea(
        child: Obx(() {
          // Show loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD4A373)),
              ),
            );
          }
          
          // Show error state
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: controller.retryFetch,
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
          
          // Show empty state
          if (controller.currentUser.value == null) {
            return const Center(
              child: Text(
                'No profile data available',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            );
          }
          
          // Show profile content
          return _buildProfileContent(context);
        }),
      ),
    );
  }
  
  Widget _buildProfileContent(BuildContext context) {
    return Column(
      children: [
        // Header with back button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: SvgPicture.asset(
                  'assets/svg/profile/personal/left_arrow_5.svg',
                  width: 20,
                  height: 20,
                  colorFilter: const ColorFilter.mode(
                    Color(0xFFD4A373),
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const Expanded(
                child: Text(
                  'Profile',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontFamily: 'PlayfairDisplay',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
        
        // Main content
        Expanded(
          child: Container(
            color: const Color(0xFF2E3A59),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Main profile image - clean without overlays
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    height: 520,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Obx(() {
                      if (controller.galleryImages.isEmpty) {
                        // Empty state - no image available
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A4A6B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.white54,
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No photo available',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        // Show the first image from gallery
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: DecorationImage(
                              image: NetworkImage(controller.galleryImages.first),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }
                    }),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Photo Gallery Section
                  if (controller.galleryImages.length > 1) _buildPhotoGallery(),
                  
                  const SizedBox(height: 24),
                  
                  // Name - under the image
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Obx(() => Text(
                        '${controller.name}, ${controller.age}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontFamily: 'PlayfairDisplay',
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(height: 4),
                  
                  // Location on left, message icon on right - under name
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Obx(() => Text(
                          controller.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: 'inter',
                          ),
                        )),
                        const Spacer(),
                        Transform.translate(
                          offset: const Offset(0, -40),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF21293F),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF21293F).withValues(alpha: 0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: SvgPicture.asset(
                                'assets/svg/Chat.svg',
                                width: 32,
                                height: 32,
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFFD4A373),
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Divider line
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 1,
                    color: const Color(0xFF594430),
                    width: double.infinity,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Looking for section with yellow icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFFD4A373),
                          size: 17,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Looking for',
                          style: TextStyle(
                            color: Color(0xFFD4A373),
                            fontSize: 18,
                            fontFamily: 'PlayfairDisplay',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bio
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() => Text(
                      controller.bio,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'PlayfairDisplay',
                        fontWeight: FontWeight.w500,
                      ),
                    )),
                  ),
                  
                  // About Me section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svg/profile/Coma.svg',
                              height: 18,
                              width: 18,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFFD4A373),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'About Me',
                              style: TextStyle(
                                color: Color(0xFFD4A373),
                                fontSize: 18,
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Obx(() => Text(
                          controller.bio.isNotEmpty ? controller.bio : 'No bio available',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Inter',
                            height: 1.5,
                          ),
                        )),
                      ],
                    ),
                  ),
                  
                  // Interests section
                  if (controller.interests.isNotEmpty) _buildInterestsSection(),
                  
                  // Basic Info section
                  _buildBasicInfoSection(),
                  
                  // Lifestyle section
                  _buildLifestyleSection(),
                  
                  // Habits section
                  _buildHabitsSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInterestsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21293F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    size: 18,
                    color: const Color(0xFFD4A373),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Interests',
                    style: TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.interests.map((interest) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A373).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4A373).withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    interest,
                    style: const TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 12,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBasicInfoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21293F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'assets/svg/profile/informations.svg',
                    height: 18,
                    width: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFD4A373),
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Basic Info',
                    style: TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                children: [
                  if (controller.jobTitle.isNotEmpty) _InfoSection(title: 'Job', value: controller.jobTitle),
                  if (controller.education.isNotEmpty) _InfoSection(title: 'Education', value: controller.education),
                  _InfoSection(title: 'Height', value: controller.height),
                  _InfoSection(title: 'Weight', value: controller.weight),
                  if (controller.religion.isNotEmpty) _InfoSection(title: 'Religion', value: controller.religion),
                  if (controller.zodiacSign.isNotEmpty) _InfoSection(title: 'Zodiac Sign', value: controller.zodiacSign),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLifestyleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21293F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.style,
                    size: 18,
                    color: const Color(0xFFD4A373),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Lifestyle',
                    style: TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                children: [
                  if (controller.sleepingStyle.isNotEmpty) _InfoSection(title: 'Sleeping Style', value: controller.sleepingStyle),
                  if (controller.loveStyle.isNotEmpty) _InfoSection(title: 'Love Style', value: controller.loveStyle),
                  if (controller.weekends.isNotEmpty) _InfoSection(title: 'Weekends', value: controller.weekends),
                  if (controller.traveling.isNotEmpty) _InfoSection(title: 'Traveling', value: controller.traveling),
                  if (controller.homeEnvironment.isNotEmpty) _InfoSection(title: 'Home Environment', value: controller.homeEnvironment),
                  if (controller.livingSpace.isNotEmpty) _InfoSection(title: 'Living Space', value: controller.livingSpace),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHabitsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21293F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 18,
                    color: const Color(0xFFD4A373),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Habits',
                    style: TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => Column(
                children: [
                  if (controller.communicationStyle.isNotEmpty) _InfoSection(title: 'Communication Style', value: controller.communicationStyle.join(', ')),
                  if (controller.workout.isNotEmpty) _InfoSection(title: 'Workout', value: controller.workout),
                  if (controller.eatingStyle.isNotEmpty) _InfoSection(title: 'Eating Style', value: controller.eatingStyle.join(', ')),
                  if (controller.socialMedia.isNotEmpty) _InfoSection(title: 'Social Media', value: controller.socialMedia),
                  if (controller.smokeOrDrink.isNotEmpty) _InfoSection(title: 'Smoke or Drink', value: controller.smokeOrDrink),
                  if (controller.newExperiences.isNotEmpty) _InfoSection(title: 'New Experiences', value: controller.newExperiences),
                ],
              )),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPhotoGallery() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF21293F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD4A373).withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A373).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 18,
                    color: const Color(0xFFD4A373),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Photos',
                    style: TextStyle(
                      color: Color(0xFFD4A373),
                      fontSize: 18,
                      fontFamily: 'PlayfairDisplay',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    '${controller.galleryImages.length} photos',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  )),
                ],
              ),
            ),
            // Card content - Photo grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: controller.galleryImages.length > 6 ? 6 : controller.galleryImages.length,
                itemBuilder: (context, index) {
                  // Skip the first image since it's already shown as the main profile image
                  final imageIndex = index + 1;
                  if (imageIndex >= controller.galleryImages.length) {
                    return Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A4A6B),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          color: Colors.white54,
                          size: 24,
                        ),
                      ),
                    );
                  }
                  
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      controller.galleryImages[imageIndex],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A4A6B),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white54,
                              size: 24,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final String value;

  const _InfoSection({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFFD4A373),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

