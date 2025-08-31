import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/edit_profile_controller.dart';

class EditProfile extends GetView<ProfileEditController> {
  // Sample internet photos for demonstration
  final List<String> samplePhotos = [
    'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=300&h=400&fit=crop',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&h=400&fit=crop',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=300&h=400&fit=crop',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=300&h=400&fit=crop',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=300&h=400&fit=crop',
    'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?w=300&h=400&fit=crop',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F1419),
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      
                      // Profile Complete Section
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E2A3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  '23%',
                                  style: TextStyle(
                                    color: Color(0xFF4A9EFF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(0xFF2A3441),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: 0.23,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4A9EFF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Please complete your profile, it will help to find best\nmatches for you',
                              style: TextStyle(
                                color: Color(0xFF8B9CAD),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // About Me Section
                      Text(
                        'About Me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E2A3A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: TextEditingController(text: controller.aboutMe.value),
                          onChanged: (value) => controller.aboutMe.value = value,
                          maxLines: 4,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'PerifareDisplay',
                          ),
                          decoration: InputDecoration(
                            hintText: 'Type here...',
                            hintStyle: TextStyle(
                              color: Color(0xFF5A6B7D),
                              fontSize: 14,
                              fontFamily: 'PerifareDisplay',
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Photos Section
                      Text(
                        'Photos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Add up to 9 Photos. First photo shows on your profile.',
                        style: TextStyle(
                          color: Color(0xFF8B9CAD),
                          fontSize: 13,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Photo Grid with Internet Photos
                      GridView.count(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                        children: [
                          // Display existing photos or sample photos
                          ...List.generate(9, (index) {
                            if (index < controller.photos.length && controller.photos[index].isNotEmpty) {
                              return _buildPhotoSlot(controller.photos[index], index);
                            } else if (index < samplePhotos.length) {
                              return _buildSamplePhotoSlot(samplePhotos[index], index);
                            } else {
                              return _buildAddPhotoSlot(index, context);
                            }
                          }),
                        ],
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Personal Information
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Name Field
                      _buildInfoField('Name', controller.name),
                      
                      SizedBox(height: 16),
                      
                      // Age and Gender Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Age', controller.age),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Gender', controller.gender),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Height and Weight Row
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Height', controller.height),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Weight', controller.weight),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: 16),
                      
                      // Education
                      _buildInfoField('Education', controller.education),
                      
                      SizedBox(height: 16),
                      
                      // Job Status
                      _buildInfoField('Job Status', controller.jobStatus),
                      
                      SizedBox(height: 16),
                      
                      // Location
                      _buildInfoField('Location', controller.location),
                      
                      SizedBox(height: 16),
                      
                      // Interested In
                      _buildInfoField('Interested In', controller.interestedIn),
                      
                      SizedBox(height: 16),
                      
                      // Looking For
                      _buildInfoField('Looking For', controller.lookingFor),
                      
                      SizedBox(height: 32),
                      
                      // Personal Traits
                      Text(
                        'Personal Traits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Traits Grid
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildTraitChip('Ambition'),
                          _buildTraitChip('Confidence'),
                          _buildTraitChip('Generosity'),
                          _buildTraitChip('Humility'),
                          _buildTraitChip('Kindness'),
                          _buildTraitChip('Loyalty'),
                        ],
                      ),
                      
                      SizedBox(height: 24),
                      
                      // Interests
                      _buildExpandableSection('Interests'),
                      
                      SizedBox(height: 16),
                      
                      // Interests Tags
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildInterestChip('Painting'),
                          _buildInterestChip('Content creation'),
                          _buildInterestChip('Camping'),
                          _buildInterestChip('Hot'),
                        ],
                      ),
                      
                      SizedBox(height: 32),
                      
                      // Basics
                      Text(
                        'Basics',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Basics Items
                      _buildBasicItem('Zodiac', controller.zodiac),
                      _buildBasicItem('Education', controller.education),
                      _buildBasicItem('Job', controller.jobStatus),
                      _buildBasicItem('Religion', controller.religion),
                      
                      SizedBox(height: 32),
                      
                      // Lifestyle
                      Text(
                        'Lifestyle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Lifestyle Items
                      _buildBasicItem('Sleeping style', controller.sleepingStyle),
                      _buildBasicItem('Love style', controller.loveStyle),
                      _buildBasicItem('Weekends', controller.weekend),
                      _buildBasicItem('Travelling', controller.travelling),
                      _buildBasicItem('Home environment', controller.homeEnvironment),
                      _buildBasicItem('Living Space', controller.livingSpace),
                      
                      SizedBox(height: 32),
                      
                      // Habits
                      Text(
                        'Habits',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'PerifareDisplay',
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Habits Items
                      _buildBasicItem('Communication style', controller.communicationStyle),
                      _buildBasicItem('Workout', controller.workout),
                      _buildBasicItem('Eating style', controller.eatingStyle),
                      _buildBasicItem('Social media', controller.socialMedia),
                      _buildBasicItem('Smoke or drink', controller.smokeOrDrink),
                      _buildBasicItem('New experiences', controller.newExperiences),
                      
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(String imagePath, int index) {
    final hasImage = imagePath.isNotEmpty;
    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E2A3A),
            borderRadius: BorderRadius.circular(12),
            image: hasImage
                ? DecorationImage(
                    image: NetworkImage(imagePath),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: hasImage
              ? Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => controller.removePhoto(index),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Container(),
        ));
  }

  // New method for sample photos from internet
  Widget _buildSamplePhotoSlot(String imagePath, int index) {
    return GestureDetector(
      onTap: () {
        // Add this sample photo to user's photos
        controller.addPhoto(imagePath);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E2A3A),
          borderRadius: BorderRadius.circular(12),
          image: DecorationImage(
            image: NetworkImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Color(0xFF4A9EFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            // Optional: Add a subtle overlay to indicate it's a sample
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Color(0xFF4A9EFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddPhotoSlot(int index, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Show dialog to choose from sample photos or add custom
        _showPhotoSelectionDialog(context, index);
      },
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: Color(0xFF1E2A3A).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF4A9EFF),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Container(
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Color(0xFF4A9EFF),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color(0xFF4A9EFF),
                      width: 1.5,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Color(0xFF4A9EFF),
                    size: 24,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Add Image',
                  style: TextStyle(
                    color: Color(0xFF4A9EFF),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PerifareDisplay',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Dialog to select photos from internet
  void _showPhotoSelectionDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Color(0xFF1E2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Choose Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PerifareDisplay',
                  ),
                ),
                SizedBox(height: 20),
                
                // Sample photos grid
                Container(
                  height: 300,
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    children: samplePhotos.map((photo) => GestureDetector(
                      onTap: () {
                        controller.addPhoto(photo);
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(photo),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )).toList(),
                  ),
                ),
                
                SizedBox(height: 20),
                
                // Close button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Color(0xFF4A9EFF),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoField(String label, dynamic value) {
    String getDisplayValue() {
      if (value == null) return '';
      if (value is RxInt) return value.value.toString();
      if (value is RxString) return value.value;
      if (value is Rx) return value.value?.toString() ?? '';
      return value.toString();
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Text(
                  label,
                  style: TextStyle(
                    color: Color(0xFF8B9CAD),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'PerifareDisplay',
                  ),
                ),
              if (label.isNotEmpty) SizedBox(height: 2),
              Obx(() => Text(
                    getDisplayValue().isEmpty ? label : getDisplayValue(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PerifareDisplay',
                    ),
                  )),
            ],
          ),
          Icon(
            Icons.chevron_right,
            color: Color(0xFF5A6B7D),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildTraitChip(String trait) {
    return Obx(() => GestureDetector(
          onTap: () => controller.toggleTrait(trait),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: controller.selectedTraits.contains(trait)
                  ? Color(0xFF4A9EFF).withOpacity(0.2)
                  : Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.selectedTraits.contains(trait)
                    ? Color(0xFF4A9EFF)
                    : Color(0xFF3A4B5C),
                width: 1,
              ),
            ),
            child: Text(
              trait,
              style: TextStyle(
                color: controller.selectedTraits.contains(trait)
                    ? Color(0xFF4A9EFF)
                    : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'PerifareDisplay',
              ),
            ),
          ),
        ));
  }

  Widget _buildExpandableSection(String title) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF5A6B7D),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: 'PerifareDisplay',
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Color(0xFF5A6B7D),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String interest) {
    return Obx(() => GestureDetector(
          onTap: () => controller.toggleInterest(interest),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: controller.selectedInterests.contains(interest)
                  ? Color(0xFF4A9EFF).withOpacity(0.2)
                  : Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.selectedInterests.contains(interest)
                    ? Color(0xFF4A9EFF)
                    : Color(0xFF3A4B5C),
                width: 1,
              ),
            ),
            child: Text(
              interest,
              style: TextStyle(
                color: controller.selectedInterests.contains(interest)
                    ? Color(0xFF4A9EFF)
                    : Color(0xFF8B9CAD),
                fontSize: 13,
                fontWeight: FontWeight.w500,
                fontFamily: 'PerifareDisplay',
              ),
            ),
          ),
        ));
  }

  Widget _buildBasicItem(String label, RxString value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'PerifareDisplay',
            ),
          ),
          Row(
            children: [
              Obx(() => Text(
                    value.value,
                    style: TextStyle(
                      color: Color(0xFF8B9CAD),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'PerifareDisplay',
                    ),
                  )),
              SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: Color(0xFF5A6B7D),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}