import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
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
    // Debug: Check if profile data is loading
    print('DEBUG: Building EditProfile view');
    print('DEBUG: Is loading: ${controller.isLoading.value}');
    print('DEBUG: User profile: ${controller.userProfile.value}');
    print('DEBUG: Profile completion: ${controller.profileCompletion.value}%');
    print('DEBUG: User name: ${controller.userProfile.value?.firstName ?? 'No name'}');
    
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
                            // Name Section
                            Obx(() {
                              print('DEBUG: Name widget rebuilding');
                              final name = controller.userProfile.value?.firstName ?? 'No name';
                              print('DEBUG: Displaying name: $name');
                              return Text(
                                name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                            SizedBox(height: 16),
                            Obx(() {
                              print('DEBUG: Profile completion widget rebuilding');
                              print('DEBUG: Current completion: ${controller.profileCompletion.value}%');
                              return Row(
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
                                    '${controller.profileCompletion}%',
                                    style: TextStyle(
                                      color: Color(0xFF4A9EFF),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
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
                        child: Obx(() => TextField(
                          controller: TextEditingController(text: controller.userProfile.value?.aboutMe ?? ''),
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
                        )),
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
                        final userPhotos = controller.userProfile.value?.image ?? [];
                        print('DEBUG: User photos count: ${userPhotos.length}');
                        print('DEBUG: User photos: $userPhotos');
                        
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
                              if (index < userPhotos.length && userPhotos[index].isNotEmpty) {
                                print('DEBUG: Building user photo slot $index with: ${userPhotos[index]}');
                                return _buildPhotoSlot(userPhotos[index], index);
                              } else if (index < samplePhotos.length) {
                                print('DEBUG: Building sample photo slot $index');
                                return _buildSamplePhotoSlot(samplePhotos[index], index);
                              } else {
                                print('DEBUG: Building add photo slot $index');
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
                      Obx(() => _buildInfoField('Name', controller.userProfile.value?.firstName ?? '')),
                      
                      SizedBox(height: 16),
                      
                      // Age and Gender Row
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Age', controller.userProfile.value?.age.toString() ?? ''),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Gender', controller.userProfile.value?.gender ?? ''),
                          ),
                        ],
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Height and Weight Row (using lifestyle data if available)
                      Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildInfoField('Height', controller.userProfile.value?.lifestyle?.sleepingStyle ?? ''), // Using sleepingStyle as placeholder for height
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildInfoField('Weight', controller.userProfile.value?.lifestyle?.loveStyle ?? ''), // Using loveStyle as placeholder for weight
                          ),
                        ],
                      )),
                      
                      SizedBox(height: 16),
                      
                      // Education (using lifestyle data if available)
                      Obx(() => _buildInfoField('Education', controller.userProfile.value?.lifestyle?.weekends ?? '')), // Using weekends as placeholder for education
                      
                      SizedBox(height: 16),
                      
                      // Job Status (using lifestyle data if available)
                      Obx(() => _buildInfoField('Job Status', controller.userProfile.value?.lifestyle?.traveling ?? '')), // Using traveling as placeholder for job status
                      
                      SizedBox(height: 16),
                      
                      // Location (using coordinates)
                      Obx(() => _buildInfoField('Location', controller.userProfile.value?.location != null ? 'Location set' : 'No location set')),
                      
                      SizedBox(height: 16),
                      
                      // Interested In (using relationType)
                      Obx(() => _buildInfoField('Interested In', controller.userProfile.value?.relationType ?? '')),
                      
                      SizedBox(height: 16),
                      
                      // Looking For (using likeToMeet data)
                      Obx(() => _buildInfoField('Looking For', controller.userProfile.value?.likeToMeet.join(', ') ?? '')),
                      
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
                        children: controller.userProfile.value?.personalTraitsInspire.map((trait) => _buildTraitChip(trait)).toList() ?? [],
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
                          ...controller.userProfile.value?.interests?.hobbies.map((interest) => _buildInterestChip(interest)) ?? [],
                          // Display creative outlets
                          ...controller.userProfile.value?.interests?.creativeOutlets.map((interest) => _buildInterestChip(interest)) ?? [],
                          // Display fitness and sports
                          ...controller.userProfile.value?.interests?.fitnessAndSports.map((interest) => _buildInterestChip(interest)) ?? [],
                          // Display entertainment
                          ...controller.userProfile.value?.interests?.entertainment.map((interest) => _buildInterestChip(interest)) ?? [],
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
                      Obx(() => _buildBasicItem('Zodiac', (controller.userProfile.value?.zodiacSign ?? '').obs)),
                      Obx(() => _buildBasicItem('Education', (controller.userProfile.value?.lifestyle?.weekends ?? '').obs)), // Using weekends as placeholder for education
                      Obx(() => _buildBasicItem('Job', (controller.userProfile.value?.lifestyle?.traveling ?? '').obs)), // Using traveling as placeholder for job
                      Obx(() => _buildBasicItem('Religion', (controller.userProfile.value?.religion ?? '').obs)),
                      
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
                      Obx(() => _buildBasicItem('Sleeping style', (controller.userProfile.value?.lifestyle?.sleepingStyle ?? '').obs)),
                      Obx(() => _buildBasicItem('Love style', (controller.userProfile.value?.lifestyle?.loveStyle ?? '').obs)),
                      Obx(() => _buildBasicItem('Weekends', (controller.userProfile.value?.lifestyle?.weekends ?? '').obs)),
                      Obx(() => _buildBasicItem('Travelling', (controller.userProfile.value?.lifestyle?.traveling ?? '').obs)),
                      Obx(() => _buildBasicItem('Home environment', (controller.userProfile.value?.lifestyle?.homeEnvironment ?? '').obs)),
                      Obx(() => _buildBasicItem('Living Space', (controller.userProfile.value?.lifestyle?.livingSpace ?? '').obs)),
                      
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
                      Obx(() {
                        final habits = controller.userProfile.value?.habits;
                        print('DEBUG: Habits object exists: ${habits != null}');
                        if (habits != null) {
                          print('DEBUG: Habits object: $habits');
                        }
                        
                        final workoutData = controller.userProfile.value?.habits?.workout ?? '';
                        final eatingStyleData = controller.userProfile.value?.habits?.eatingStyle.join(', ') ?? '';
                        final socialMediaData = controller.userProfile.value?.habits?.socialMedia ?? '';
                        final smokeOrDrinkData = controller.userProfile.value?.habits?.smokeOrDrink ?? '';
                        final newExperiencesData = controller.userProfile.value?.habits?.newExercise ?? '';
                        
                        print('DEBUG: Habits data - Workout: $workoutData');
                        print('DEBUG: Habits data - Eating style: $eatingStyleData');
                        print('DEBUG: Habits data - Social media: $socialMediaData');
                        print('DEBUG: Habits data - Smoke or drink: $smokeOrDrinkData');
                        print('DEBUG: Habits data - New experiences: $newExperiencesData');
                        
                        return Column(
                          children: [
                            _buildBasicItem('Communication style', (controller.userProfile.value?.habits?.communicationStyle.join(', ') ?? '').obs),
                            _buildBasicItem('Workout', workoutData.obs),
                            _buildBasicItem('Eating style', eatingStyleData.obs),
                            _buildBasicItem('Social media', socialMediaData.obs),
                            _buildBasicItem('Smoke or drink', smokeOrDrinkData.obs),
                            _buildBasicItem('New experiences', newExperiencesData.obs),
                          ],
                        );
                      }),
                      
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
    
    // Debug: Print image path information
    print('DEBUG: Building photo slot $index with path: $imagePath');
    print('DEBUG: Has image: $hasImage');
    
    // Determine if the image path is a network URL or local file
    ImageProvider? imageProvider;
    if (hasImage) {
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // Network image
        print('DEBUG: Using NetworkImage for: $imagePath');
        imageProvider = NetworkImage(imagePath);
      } else if (File(imagePath).existsSync()) {
        // Local file
        print('DEBUG: Using FileImage for: $imagePath');
        imageProvider = FileImage(File(imagePath));
      } else {
        // Fallback to network image if file doesn't exist
        print('DEBUG: File does not exist, trying NetworkImage for: $imagePath');
        imageProvider = NetworkImage(imagePath);
      }
    } else {
      print('DEBUG: No image path provided for slot $index');
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
                  print('DEBUG: Error loading image: $imagePath');
                  print('DEBUG: Error: $exception');
                },
              )
            : null,
      ),
      child: hasImage
          ? Stack(
              children: [
                // Fallback UI in case image fails to load
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
    );
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
    
    // Check if the value is reactive (Rx type)
    bool isReactive = value is Rx;
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
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
                // Only use Obx if the value is reactive, otherwise use a regular Text widget
                isReactive 
                  ? Obx(() => Text(
                        getDisplayValue().isEmpty ? label : getDisplayValue(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'PerifareDisplay',
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ))
                  : Text(
                      getDisplayValue().isEmpty ? label : getDisplayValue(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'PerifareDisplay',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
              ],
            ),
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
            ],
          ),
        ],
      ),
    );
  }
}