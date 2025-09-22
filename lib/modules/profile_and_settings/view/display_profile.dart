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
        child: Column(
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
                          image: const DecorationImage(
                            image: NetworkImage('https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=600&fit=crop&crop=face'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      
                      // Name - under the image
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Obx(() => Text(
                            '${controller.name.value}, ${controller.age.value}',
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
                              controller.location.value,
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
                                        color: const Color(0xFF21293F).withOpacity(0.4),
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
                      
                      // Casual Connection
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Obx(() => Text(
                          controller.bio.value,
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
                            const Text(
                              'I\'m a mix of curiosity and kindness, always up for good conversation, genuine laughs, and new adventures. Life\'s too short for anything less than connections.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontFamily: 'PlayfairDisplay',
                                height: 1.5,
                              ),
                            )
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Photos section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Photos',
                              style: TextStyle(
                                color: Color(0xFFD4A373),
                                fontSize: 20,
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // First row of photos
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&h=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&h=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=300&h=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Second row of photos
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=300&h=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: const DecorationImage(
                                        image: NetworkImage('https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(child: SizedBox()), // Empty space to match layout
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Personal Information section
                      const _InfoSection(
                        title: 'Personal Information',
                        titleColor: Color(0xFFD4A373),
                        items: [
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/Group.svg',
                            text: 'Woman (She/her/hers)',
                          ),
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/single.svg',
                            text: 'Single',
                          ),
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/height.svg',
                            text: '171 cm, 64 kg',
                          ),
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/job.svg',
                            text: 'Fashion designer',
                          ),
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/edu.svg',
                            text: 'Oxford brookes university',
                          ),
                          _InfoWithIcon(
                            icon: 'assets/svg/profile/personal/home.svg',
                            text: 'California, USA',
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Divider line
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0),
                        height: 1,
                        color: const Color(0xFF594430),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Personal Traits section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Traits',
                              style: TextStyle(
                                color: Color(0xFFD4A373),
                                fontSize: 20,
                                fontFamily: 'PlayfairDisplay',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(child: _buildTraitBadge('Ambition')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTraitBadge('Confidence')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTraitBadge('Generosity')),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _buildTraitBadge('Humility')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTraitBadge('Kindness')),
                                const SizedBox(width: 10),
                                Expanded(child: _buildTraitBadge('Loyalty')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Basics section
                      const _DetailSection(
                        title: 'Basics',
                        titleColor: Color(0xFFD4A373),
                        items: [
                          _DetailItem(label: 'Zodiac', value: 'Leo'),
                          _DetailItem(label: 'Education', value: 'Bachelor'),
                          _DetailItem(label: 'Religion', value: 'Christian'),
                          _DetailItem(label: 'Job', value: 'UX/UI designer'),
                          _DetailItem(label: 'Yearly income', value: '\$100,000'),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Lifestyle section
                      const _DetailSection(
                        title: 'Lifestyle',
                        titleColor: Color(0xFFD4A373),
                        items: [
                          _DetailItem(label: 'Sleeping style', value: 'Night owl'),
                          _DetailItem(label: 'Love style', value: 'Thoughtful gestures'),
                          _DetailItem(label: 'Weekends', value: 'Relaxing home'),
                          _DetailItem(label: 'Traveling', value: 'Occasionally'),
                          _DetailItem(label: 'Home environment', value: 'Quiet and clean'),
                          _DetailItem(label: 'Living Space', value: 'Very organized'),
                        ],
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Habits section
                      const _DetailSection(
                        title: 'Habits',
                        titleColor: Color(0xFFD4A373),
                        items: [
                          _DetailItem(label: 'Communication Style', value: 'Good texter'),
                          _DetailItem(label: 'Workout', value: 'Rarely'),
                          _DetailItem(label: 'Eating style', value: 'Balanced'),
                          _DetailItem(label: 'Social media', value: 'Frequently'),
                          _DetailItem(label: 'Smoke/drink', value: 'Occasionally'),
                          _DetailItem(label: 'Sleep schedule', value: 'Sometimes'),
                        ],
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitBadge(String trait) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF21293F),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          trait,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final Color titleColor;

  const _InfoSection({
    required this.title,
    required this.items,
    this.titleColor = const Color(0xFFD4A373),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }
}

class _InfoWithIcon extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoWithIcon({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SvgPicture.asset(
            icon,
            height: 20,
            width: 20,
            colorFilter: const ColorFilter.mode(
              Color(0xFFB6B6B6),
              BlendMode.srcIn,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontFamily: 'PlayfairDisplay',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final Color titleColor;

  const _DetailSection({
    required this.title,
    required this.items,
    this.titleColor = const Color(0xFFD4A373),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 20,
              fontFamily: 'PlayfairDisplay',
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF21293F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                for (int i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      height: 1,
                      color: Colors.white.withOpacity(0.1),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 14,
            fontFamily: 'PlayfairDisplay',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}