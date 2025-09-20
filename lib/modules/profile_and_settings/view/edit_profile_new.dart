import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/edit_profile_controller.dart';

class EditProfileNew extends GetView<ProfileEditController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A2332),
              Color(0xFF0F1419),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              _buildProfileHeader(),
              SizedBox(height: 24),
              
              // Basic Information
              _buildSection('Basic Information', _buildBasicInfo()),
              SizedBox(height: 24),
              
              // Habits
              _buildSection('Habits', _buildHabits()),
              SizedBox(height: 24),
              
              // Interests
              _buildSection('Interests', _buildInterests()),
              SizedBox(height: 24),
              
              // Lifestyle
              _buildSection('Lifestyle', _buildLifestyle()),
              SizedBox(height: 24),
              
              // Personal Traits
              _buildSection('Personal Traits', _buildPersonalTraits()),
              SizedBox(height: 24),
              
              // Looking For
              _buildSection('Looking For', _buildLookingFor()),
              SizedBox(height: 32),
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Obx(() {
      final profile = controller.userProfile.value;
      return Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF4A9EFF), width: 1),
        ),
        child: Column(
          children: [
            // Profile Completion
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Profile Complete',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${controller.profileCompletion.value}%',
                  style: TextStyle(
                    color: Color(0xFF4A9EFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            LinearProgressIndicator(
              value: controller.profileCompletion.value / 100,
              backgroundColor: Color(0xFF2A3441),
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A9EFF)),
            ),
            SizedBox(height: 16),
            
            // Name and Basic Info
            Text(
              '${profile?.firstName ?? ''} ${profile?.lastName ?? ''}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${profile?.age ?? ''} • ${profile?.gender ?? ''}',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              profile?.email ?? '',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Obx(() {
      final profile = controller.userProfile.value;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildInfoRow('Age', profile?.age?.toString() ?? 'Not set'),
            _buildInfoRow('Gender', profile?.gender ?? 'Not set'),
            _buildInfoRow('Religion', profile?.religion ?? 'Not set'),
            _buildInfoRow('Zodiac Sign', profile?.zodiacSign ?? 'Not set'),
            _buildInfoRow('Relationship Type', profile?.relationType ?? 'Not set'),
            _buildInfoRow('About Me', profile?.aboutMe ?? 'Not set'),
          ],
        ),
      );
    });
  }

  Widget _buildHabits() {
    return Obx(() {
      final habits = controller.userProfile.value?.habits;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildInfoRow('Workout', habits?.workout ?? 'Not set'),
            _buildInfoRow('Social Media', habits?.socialMedia ?? 'Not set'),
            _buildInfoRow('Smoke/Drink', habits?.smokeOrDrink ?? 'Not set'),
            _buildInfoRow('New Exercise', habits?.newExercise ?? 'Not set'),
            _buildInfoRow('Communication Style', habits?.communicationStyle.join(', ') ?? 'Not set'),
            _buildInfoRow('Eating Style', habits?.eatingStyle.join(', ') ?? 'Not set'),
          ],
        ),
      );
    });
  }

  Widget _buildInterests() {
    return Obx(() {
      final interests = controller.userProfile.value?.interests;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Hobbies', interests?.hobbies.join(', ') ?? 'None'),
            _buildInfoRow('Creative Outlets', interests?.creativeOutlets.join(', ') ?? 'None'),
            _buildInfoRow('Fitness & Sports', interests?.fitnessAndSports.join(', ') ?? 'None'),
            _buildInfoRow('Entertainment', interests?.entertainment.join(', ') ?? 'None'),
            _buildInfoRow('Leisure Activities', interests?.leisureActivities.join(', ') ?? 'None'),
            _buildInfoRow('Music Genres', interests?.musicGenres.join(', ') ?? 'None'),
            _buildInfoRow('Health & Wellness', interests?.healthAndWellness.join(', ') ?? 'None'),
            _buildInfoRow('Reading & Content', interests?.readingAndContent.join(', ') ?? 'None'),
          ],
        ),
      );
    });
  }

  Widget _buildLifestyle() {
    return Obx(() {
      final lifestyle = controller.userProfile.value?.lifestyle;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildInfoRow('Sleeping Style', lifestyle?.sleepingStyle ?? 'Not set'),
            _buildInfoRow('Love Style', lifestyle?.loveStyle ?? 'Not set'),
            _buildInfoRow('Weekends', lifestyle?.weekends ?? 'Not set'),
            _buildInfoRow('Traveling', lifestyle?.traveling ?? 'Not set'),
            _buildInfoRow('Home Environment', lifestyle?.homeEnvironment ?? 'Not set'),
            _buildInfoRow('Living Space', lifestyle?.livingSpace ?? 'Not set'),
          ],
        ),
      );
    });
  }

  Widget _buildPersonalTraits() {
    return Obx(() {
      final traits = controller.userProfile.value?.personalTraitsInspire;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Traits that inspire you:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: traits?.map((trait) => _buildChip(trait)).toList() ?? [],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildLookingFor() {
    return Obx(() {
      final likeToMeet = controller.userProfile.value?.likeToMeet;
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF1A2332),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Looking to meet:',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: likeToMeet?.map((item) => _buildChip(item)).toList() ?? [],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFF4A9EFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement save functionality
          Get.back();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF4A9EFF),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Save Changes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
