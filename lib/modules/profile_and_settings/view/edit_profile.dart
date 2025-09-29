import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:kindered_app/modules/profile_and_settings/controller/edit_profile_controller.dart';

class EditProfile extends GetView<ProfileEditController> {
   const EditProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2E3A59),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2E3A59),
              Color(0xFF2E3A59),
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
                        fontFamily: 'PerifareDisplay',
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
                            // Name Section
                            Obx(() {
                              final name = controller.userFirstName;
                              return Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'PerifareDisplay',
                                ),
                              );
                            }),
                            SizedBox(height: 16),
                            Obx(() {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Profile Complete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'PerifareDisplay',
                                    ),
                                  ),
                                  Text(
                                    '${controller.profileCompletion}%',
                                    style: TextStyle(
                                      color: Color(0xFF4A9EFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'PerifareDisplay',
                                    ),
                                  ),
                                ],
                              );
                            }),
                            SizedBox(height: 8),
                            Obx(() => Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: Color(0xFF2A3441),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: controller.profileCompletion / 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFF4A9EFF),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            )),
                            SizedBox(height: 12),
                            Text(
                              'Please complete your profile, it will help to find best\nmatches for you',
                              style: TextStyle(
                                color: Color(0xFF8B9CAD),
                                fontSize: 13,
                                height: 1.4,
                                fontFamily: 'PerifareDisplay',
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: controller.aboutMeController,
                              onChanged: (value) => controller.updateAboutMe(value),
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
                            SizedBox(height: 8),
                            // Update button for about me
                            Obx(() => ElevatedButton(
                              onPressed: controller.isAboutMeDirty.value 
                                  ? () => controller.submitAboutMe() 
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isAboutMeDirty.value 
                                    ? Color(0xFF4A9EFF) 
                                    : Color(0xFF2A3441),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Update About Me',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'PerifareDisplay',
                                      ),
                                    ),
                            )),
                          ],
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
                      
                      // Photo Grid with dynamic photos
                      Obx(() {
                        return GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                          children: [
                            // Display existing photos or sample photos
                            ...List.generate(9, (index) {
                              if (index < controller.userPhotos.length) {
                                return _buildPhotoSlot(controller.userPhotos[index], index);
                              } else {
                                return _buildAddPhotoSlot(index, context);
                              }
                            }),
                          ],
                        );
                      }),
                      
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
                      Obx(() => _buildInfoField('Name', controller.userFirstName, isEditable: true)),
                      
                      SizedBox(height: 16),
                      
                      // Age and Gender Row
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Age', controller.userAge, isEditable: true),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Gender', controller.userGender, 
                              dropdownItems: controller.genders,
                              isEditable: true,
                            ),
                          ),
                        ],
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Height and Weight Row
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Height', controller.userHeight, isEditable: true),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Weight', controller.userWeight, isEditable: true),
                          ),
                        ],
                      )),

                      SizedBox(height: 24),

                      // Update Button for Personal Information
                      Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.updateBasicProfileInfo(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A9EFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Update Profile Information',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),

                      SizedBox(height: 32),

                      // Habits
                      Obx(() => _buildInfoField(
                        'Communication Style',
                        controller.userCommunicationStyle.join(', '),
                        dropdownItems: controller.communicationStyles,
                        isEditable: true
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Workout
                      Obx(() => _buildInfoField(
                        'Workout',
                        controller.userWorkout,
                        dropdownItems: controller.exerciseFrequencies,
                        isEditable: true
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Eating Style
                      Obx(() => _buildInfoField(
                        'Eating Style',
                        controller.userEatingStyle.join(', '),
                        dropdownItems: controller.foodPreferences,
                        isEditable: true
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Social Media Usage
                      Obx(() => _buildInfoField(
                        'Social Media',
                        controller.userSocialMedia,
                        dropdownItems: controller.socialMediaUsage,
                        isEditable: true
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Smoke or Drink
                      Obx(() => _buildInfoField(
                        'Smoke or Drink',
                        controller.userSmokeOrDrink,
                        dropdownItems: controller.smokingDrinking,
                        isEditable: true
                      )),
                      
                      SizedBox(height: 16),
                      
                      // New Experiences
                      Obx(() => _buildInfoField(
                        'New Experiences',
                        controller.userNewExperiences,
                        dropdownItems: controller.newExperienceOptions,
                        isEditable: true
                      )),
                      
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
                      Obx(() => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.userTraits.map((trait) => _buildTraitChip(trait)).toList(),
                      )),
                      
                      SizedBox(height: 24),
                      
                      // Interests
                      _buildExpandableSection('Interests'),
                      
                      SizedBox(height: 16),
                      
                      // Interests Tags
                      Obx(() => Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          // Display hobbies
                          ...controller.userInterests.where((interest) => controller.profile?.interests?.hobbies.contains(interest) ?? false).map((interest) => _buildInterestChip(interest)),
                          // Display creative outlets
                          ...controller.userInterests.where((interest) => controller.profile?.interests?.creativeOutlets.contains(interest) ?? false).map((interest) => _buildInterestChip(interest)),
                          // Display fitness and sports
                          ...controller.userInterests.where((interest) => controller.profile?.interests?.fitnessAndSports.contains(interest) ?? false).map((interest) => _buildInterestChip(interest)),
                          // Display entertainment
                          ...controller.userInterests.where((interest) => controller.profile?.interests?.entertainment.contains(interest) ?? false).map((interest) => _buildInterestChip(interest)),
                        ],
                      )),
                      
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
                      Obx(() => _buildInfoField(
                        'Zodiac',
                        controller.userZodiacSign,
                        dropdownItems: controller.zodiacSigns,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Education',
                        controller.userWeekend,
                        dropdownItems: controller.educationLevels,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Job',
                        controller.jobStatus,
                        dropdownItems: controller.jobStatuses,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Religion',
                        controller.userReligion,
                        dropdownItems: controller.religions,
                        isEditable: true
                      )),
                      
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
                      Obx(() => _buildInfoField(
                        'Sleeping Style',
                        controller.userSleepingStyle,
                        dropdownItems: controller.sleepingStyles,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Love Style',
                        controller.userLoveStyle,
                        dropdownItems: controller.loveStyles,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Weekends',
                        controller.userWeekend,
                        dropdownItems: controller.weekendStyles,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Travelling',
                        controller.userTravelling,
                        dropdownItems: controller.travelingStyles,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Home Environment',
                        controller.userHomeEnvironment,
                        dropdownItems: controller.homeEnvironments,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Living Space',
                        controller.userLivingSpace,
                        dropdownItems: controller.livingSpaces,
                        isEditable: true
                      )),
                      
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
                      Obx(() => _buildInfoField(
                        'Communication Style',
                        controller.userCommunicationStyle.join(', '),
                        dropdownItems: controller.communicationStyles,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Workout',
                        controller.userWorkout,
                        dropdownItems: controller.exerciseFrequencies,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Eating Style',
                        controller.userEatingStyle.join(', '),
                        dropdownItems: controller.foodPreferences,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Social Media',
                        controller.userSocialMedia,
                        dropdownItems: controller.socialMediaUsage,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'Smoke or Drink',
                        controller.userSmokeOrDrink,
                        dropdownItems: controller.smokingDrinking,
                        isEditable: true
                      )),
                      SizedBox(height: 16),
                      Obx(() => _buildInfoField(
                        'New Experiences',
                        controller.userNewExperiences,
                        dropdownItems: controller.newExperienceOptions,
                        isEditable: true
                      )),
                      
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
    
    ImageProvider? imageProvider;
    if (hasImage) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        imageProvider = NetworkImage(imagePath);
      } else if (File(imagePath).existsSync()) {
        imageProvider = FileImage(File(imagePath));
      } else {
        imageProvider = NetworkImage(imagePath);
      }
    } else {
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        image: hasImage && imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
                onError: (exception, stackTrace) {
                },
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
                      color: Color(0xFF1E2A3A),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Color(0xFF5A6B7D),
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
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
    );
  }


  Widget _buildAddPhotoSlot(int index, BuildContext context) {
    return GestureDetector(
      onTap: () => _showPhotoSelectionDialog(context, index),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E2A3A).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF4A9EFF).withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF4A9EFF),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.add_a_photo,
                color: Color(0xFF4A9EFF),
                size: 24,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Add Photo',
              style: TextStyle(
                color: Color(0xFF4A9EFF),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
                  ),
                ),
                SizedBox(height: 24),
                
                // Camera option
                ListTile(
                  onTap: () {
                    controller.pickImageFromCamera(index);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A9EFF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Color(0xFF4A9EFF),
                    ),
                  ),
                  title: Text(
                    'Take Photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                
                SizedBox(height: 16),
                
                // Gallery option
                ListTile(
                  onTap: () {
                    controller.pickImageFromGallery(index);
                    Navigator.pop(context);
                  },
                  leading: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF4A9EFF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Color(0xFF4A9EFF),
                    ),
                  ),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                
                SizedBox(height: 24),
                
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

  // Update the field access in _buildInfoField
  Widget _buildInfoField(String label, String value, {bool isEditable = true, List<String>? dropdownItems}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Color(0xFF8B9CAD),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          if (dropdownItems != null)
            // Dropdown field
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: dropdownItems.contains(value) ? value : null,
                hint: Text(
                  'Select $label',
                  style: TextStyle(color: Color(0xFF5A6B7D), fontSize: 16),
                ),
                dropdownColor: Color(0xFF1E2A3A),
                items: dropdownItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == null) return;
                  
                  // Match dropdown updates with controller methods
                  switch(label.toLowerCase()) {
                    case 'sleeping style':
                      controller.updateSleepingStyle(newValue);
                      break;
                    case 'love style':
                      controller.updateLoveStyle(newValue);
                      break;
                    case 'weekends':
                      controller.updateWeekend(newValue);
                      break;
                    case 'travelling':
                      controller.updateTravelling(newValue);
                      break;
                    case 'home environment':
                      controller.updateHomeEnvironment(newValue);
                      break;
                    case 'living space':
                      controller.updateLivingSpace(newValue);
                      break;
                    case 'communication style':
                      controller.updateCommunicationStyle(newValue);
                      break;
                    case 'workout':
                      controller.updateWorkout(newValue);
                      break;
                    case 'eating style':
                      controller.updateEatingStyle(newValue);
                      break;
                    case 'social media':
                      controller.updateSocialMedia(newValue);
                      break;
                    case 'smoke or drink':
                      controller.updateSmokeOrDrink(newValue);
                      break;
                    case 'new experiences':
                      controller.updateNewExperiences(newValue);
                      break;
                    case 'zodiac':
                      controller.updateZodiac(newValue);
                      break;
                    case 'education':
                      controller.updateEducation(newValue);
                      break;
                    case 'job':
                      controller.updateJobStatus(newValue);
                      break;
                    case 'religion':
                      controller.updateReligion(newValue);
                      break;
                  }
                },
              ),
            )
          else
            // Text field for editable fields
            TextFormField(
              initialValue: value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter $label',
                hintStyle: TextStyle(
                  color: Color(0xFF5A6B7D),
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                switch(label.toLowerCase()) {
                  case 'name':
                    controller.updateName(value);
                    break;
                  case 'age':
                    controller.updateAge(value);
                    break;
                  case 'gender':
                    controller.updateGender(value);
                    break;
                }
              },
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
              color: controller.userTraits.contains(trait)
                  ? Color(0xFF4A9EFF).withValues(alpha: 0.2)
                  : Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.userTraits.contains(trait)
                    ? Color(0xFF4A9EFF)
                    : Color(0xFF3A4B5C),
                width: 1,
              ),
            ),
            child: Text(
              trait,
              style: TextStyle(
                color: controller.userTraits.contains(trait)
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
              color: controller.userInterests.contains(interest)
                  ? Color(0xFF4A9EFF).withValues(alpha: 0.2)
                  : Color(0xFF1E2A3A),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: controller.userInterests.contains(interest)
                    ? Color(0xFF4A9EFF)
                    : Color(0xFF3A4B5C),
                width: 1,
              ),
            ),
            child: Text(
              interest,
              style: TextStyle(
                color: controller.userInterests.contains(interest)
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

}