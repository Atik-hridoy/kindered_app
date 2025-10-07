import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:kindered_app/modules/profile_and_settings/controller/edit_profile_controller.dart';

class EditProfile extends GetView<ProfileEditController> {
  const EditProfile({super.key});

  // Constants
  static const _primaryColor = Color(0xFF4A9EFF);
  static const _backgroundColor = Color(0xFF2E3A59);
  static const _cardColor = Color(0xFF1E2A3A);
  static const _textSecondary = Color(0xFF8B9CAD);
  static const _textTertiary = Color(0xFF5A6B7D);
  static const _fontFamily = 'PerifareDisplay';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_backgroundColor, _backgroundColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildProfileCompletionCard(),
                      const SizedBox(height: 24),
                      _buildAboutMeSection(),
                      const SizedBox(height: 24),
                      _buildPhotosSection(),
                      const SizedBox(height: 32),
                      _buildPersonalInformationSection(),
                      const SizedBox(height: 32),
                      _buildHabitsSection(),
                      const SizedBox(height: 32),
                      _buildPersonalTraitsSection(),
                      const SizedBox(height: 24),
                      _buildInterestsSection(),
                      const SizedBox(height: 32),
                      _buildBasicsSection(),
                      const SizedBox(height: 32),
                      _buildLifestyleSection(),
                      const SizedBox(height: 40),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          const Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCompletionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(
                controller.userFirstName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: _fontFamily,
                ),
              )),
          const SizedBox(height: 16),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Profile Complete',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: _fontFamily,
                    ),
                  ),
                  Text(
                    '${controller.profileCompletion}%',
                    style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: _fontFamily,
                    ),
                  ),
                ],
              )),
          const SizedBox(height: 8),
          Obx(() => Container(
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A3441),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: controller.profileCompletion / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 12),
          const Text(
            'Please complete your profile, it will help to find best\nmatches for you',
            style: TextStyle(
              color: _textSecondary,
              fontSize: 13,
              height: 1.4,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutMeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('About Me'),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: controller.aboutMeController,
                onChanged: controller.updateAboutMe,
                maxLines: 4,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: _fontFamily,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: TextStyle(
                    color: _textTertiary,
                    fontSize: 14,
                    fontFamily: _fontFamily,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => ElevatedButton(
                    onPressed: controller.isAboutMeDirty.value
                        ? controller.submitAboutMe
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isAboutMeDirty.value
                          ? _primaryColor
                          : const Color(0xFF2A3441),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Update About Me',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              fontFamily: _fontFamily,
                            ),
                          ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Photos'),
        const SizedBox(height: 8),
        const Text(
          'Add up to 9 Photos. First photo shows on your profile.',
          style: TextStyle(
            color: _textSecondary,
            fontSize: 13,
            fontFamily: _fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          final photos = controller.userPhotos;
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.75,
            children: List.generate(9, (index) {
              return index < photos.length
                  ? _buildPhotoSlot(photos[index], index)
                  : _buildAddPhotoSlot(index);
            }),
          );
        }),
      ],
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Information'),
        const SizedBox(height: 20),
        Obx(() {
          final name = controller.userFirstName;
          return _buildInfoField('Name', name, isEditable: true);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final age = controller.userAge;
                return _buildInfoField('Age', age, isEditable: true);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                final gender = controller.userGender;
                return _buildInfoField(
                  'Gender',
                  gender,
                  dropdownItems: controller.genders,
                  isEditable: true,
                );
              }),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                final height = controller.userHeight;
                return _buildInfoField('Height', height, isEditable: true);
              }),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Obx(() {
                final weight = controller.userWeight;
                return _buildInfoField('Weight', weight, isEditable: true);
              }),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Obx(() => ElevatedButton(
              onPressed: controller.isLoading.value ? null : controller.updateBasicProfileInfo,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Update Profile Information',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
            )),
      ],
    );
  }

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Habits'),
        const SizedBox(height: 16),
        Obx(() {
          final commStyle = controller.userCommunicationStyle.join(', ');
          return _buildInfoField('Communication Style', commStyle, 
              dropdownItems: controller.communicationStyles, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final workout = controller.userWorkout;
          return _buildInfoField('Workout', workout, 
              dropdownItems: controller.exerciseFrequencies, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final eatingStyle = controller.userEatingStyle.join(', ');
          return _buildInfoField('Eating Style', eatingStyle, 
              dropdownItems: controller.foodPreferences, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final socialMedia = controller.userSocialMedia;
          return _buildInfoField('Social Media', socialMedia, 
              dropdownItems: controller.socialMediaUsage, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final smokeOrDrink = controller.userSmokeOrDrink;
          return _buildInfoField('Smoke or Drink', smokeOrDrink, 
              dropdownItems: controller.smokingDrinking, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final newExp = controller.userNewExperiences;
          return _buildInfoField('New Experiences', newExp, 
              dropdownItems: controller.newExperienceOptions, isEditable: true);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildPersonalTraitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personal Traits'),
        const SizedBox(height: 16),
        Obx(() {
          final traits = controller.userTraits;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: traits.map((trait) => _buildTraitChip(trait)).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildExpandableSection('Interests'),
        const SizedBox(height: 16),
        Obx(() {
          final displayedInterests = _getDisplayedInterests();
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: displayedInterests.map((interest) => _buildInterestChip(interest)).toList(),
          );
        }),
      ],
    );
  }

  List<String> _getDisplayedInterests() {
    final interests = controller.profile?.interests;
    if (interests == null) return [];
    
    return controller.userInterests.where((interest) => 
      interests.hobbies.contains(interest) ||
      interests.creativeOutlets.contains(interest) ||
      interests.fitnessAndSports.contains(interest) ||
      interests.entertainment.contains(interest)
    ).toList();
  }

  Widget _buildBasicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basics'),
        const SizedBox(height: 16),
        Obx(() {
          final zodiac = controller.userZodiacSign;
          return _buildInfoField('Zodiac', zodiac, 
              dropdownItems: controller.zodiacSigns, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final education = controller.userWeekend;
          return _buildInfoField('Education', education, 
              dropdownItems: controller.educationLevels, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final job = controller.jobStatus;
          return _buildInfoField('Job', job, 
              dropdownItems: controller.jobStatuses, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final religion = controller.userReligion;
          return _buildInfoField('Religion', religion, 
              dropdownItems: controller.religions, isEditable: true);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLifestyleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Lifestyle'),
        const SizedBox(height: 16),
        Obx(() {
          final sleepingStyle = controller.userSleepingStyle;
          return _buildInfoField('Sleeping Style', sleepingStyle, 
              dropdownItems: controller.sleepingStyles, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final loveStyle = controller.userLoveStyle;
          return _buildInfoField('Love Style', loveStyle, 
              dropdownItems: controller.loveStyles, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final weekends = controller.userWeekend;
          return _buildInfoField('Weekends', weekends, 
              dropdownItems: controller.weekendStyles, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final travelling = controller.userTravelling;
          return _buildInfoField('Travelling', travelling, 
              dropdownItems: controller.travelingStyles, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final homeEnv = controller.userHomeEnvironment;
          return _buildInfoField('Home Environment', homeEnv, 
              dropdownItems: controller.homeEnvironments, isEditable: true);
        }),
        const SizedBox(height: 16),
        Obx(() {
          final livingSpace = controller.userLivingSpace;
          return _buildInfoField('Living Space', livingSpace, 
              dropdownItems: controller.livingSpaces, isEditable: true);
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
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
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        image: hasImage && imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover, onError: (_, __) {})
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
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
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
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }

  Widget _buildAddPhotoSlot(int index) {
    return GestureDetector(
      onTap: () => _showPhotoSelectionDialog(Get.context!, index),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _primaryColor.withValues(alpha: 0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _primaryColor, width: 2),
              ),
              child: const Icon(Icons.add_a_photo, color: _primaryColor, size: 24),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Photo',
              style: TextStyle(
                color: _primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoSelectionDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Photo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                _buildPhotoOption(
                  context,
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onTap: () {
                    controller.pickImageFromCamera(index);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildPhotoOption(
                  context,
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  onTap: () {
                    controller.pickImageFromGallery(index);
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: _primaryColor,
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

  Widget _buildPhotoOption(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: _primaryColor),
      ),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildInfoField(String label, String value, {bool isEditable = true, List<String>? dropdownItems}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          if (dropdownItems != null)
            _buildDropdownField(label, value, dropdownItems)
          else
            _buildTextField(label, value),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        isExpanded: true,
        value: items.contains(value) ? value : null,
        hint: Text('Select $label', style: const TextStyle(color: _textTertiary, fontSize: 16)),
        dropdownColor: _cardColor,
        items: items.map((item) => DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 16)),
            )).toList(),
        onChanged: (newValue) {
          if (newValue != null) _handleDropdownChange(label, newValue);
        },
      ),
    );
  }

  void _handleDropdownChange(String label, String value) {
    final handlers = {
      'sleeping style': controller.updateSleepingStyle,
      'love style': controller.updateLoveStyle,
      'weekends': controller.updateWeekend,
      'travelling': controller.updateTravelling,
      'home environment': controller.updateHomeEnvironment,
      'living space': controller.updateLivingSpace,
      'communication style': controller.updateCommunicationStyle,
      'workout': controller.updateWorkout,
      'eating style': controller.updateEatingStyle,
      'social media': controller.updateSocialMedia,
      'smoke or drink': controller.updateSmokeOrDrink,
      'new experiences': controller.updateNewExperiences,
      'zodiac': controller.updateZodiac,
      'education': controller.updateEducation,
      'job': controller.updateJobStatus,
      'religion': controller.updateReligion,
    };

    final handler = handlers[label.toLowerCase()];
    handler?.call(value);
  }

  Widget _buildTextField(String label, String value) {
    return TextFormField(
      initialValue: value,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: 'Enter $label',
        hintStyle: const TextStyle(color: _textTertiary, fontSize: 16),
        border: InputBorder.none,
      ),
      onChanged: (value) => _handleTextFieldChange(label, value),
    );
  }

  void _handleTextFieldChange(String label, String value) {
    switch (label.toLowerCase()) {
      case 'name':
        controller.updateName(value);
        break;
      case 'age':
        controller.updateAge(value);
        break;
      case 'gender':
        controller.updateGender(value);
        break;
      case 'height':
        controller.updateHeight(value);
        break;
      case 'weight':
        controller.updateWeight(value);
        break;
    }
  }

  

  Widget _buildExpandableSection(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: _textTertiary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              fontFamily: _fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  // In edit_profile.dart
// Update the _buildInterestChip method
Widget _buildInterestChip(String interest) {
  return Obx(() {
    final isSelected = controller.userInterests.contains(interest);
    return GestureDetector(
      onTap: () => controller.toggleInterest(interest),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? _primaryColor.withOpacity(0.2)
              : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryColor : const Color(0xFF3A4B5C),
            width: 1,
          ),
        ),
        child: Text(
          interest,
          style: TextStyle(
            color: isSelected ? _primaryColor : _textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: _fontFamily,
          ),
        ),
      ),
    );
  });
}

// Update the _buildTraitChip method similarly
Widget _buildTraitChip(String trait) {
  return Obx(() {
    final isSelected = controller.userTraits.contains(trait);
    return GestureDetector(
      onTap: () => controller.toggleTrait(trait),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? _primaryColor.withOpacity(0.2)
              : _cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryColor : const Color(0xFF3A4B5C),
            width: 1,
          ),
        ),
        child: Text(
          trait,
          style: TextStyle(
            color: isSelected ? _primaryColor : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: _fontFamily,
          ),
        ),
      ),
    );
  });
}
}