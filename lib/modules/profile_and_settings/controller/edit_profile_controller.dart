import 'package:get/get.dart';

class ProfileEditController extends GetxController {
  // Profile completion percentage
  var profileCompletion = 23.obs;
  
  // Personal Information
  var name = 'Alex McKinney'.obs;
  var age = 29.obs;
  var gender = 'Male'.obs;
  var height = '168 cm'.obs;
  var weight = '60 kg'.obs;
  var education = 'Bachelor'.obs;
  var jobStatus = 'UX/UI Designer'.obs;
  var location = 'California'.obs;
  var interestedIn = 'Women'.obs;
  var lookingFor = 'Casual Connection'.obs;
  
  // About me
  var aboutMe = ''.obs;
  
  // Photos
  var photos = <String>[].obs;
  
  // Personal Traits
  var selectedTraits = <String>[
    'Ambition',
    'Confidence',
    'Generosity',
    'Humility',
    'Kindness',
    'Loyalty'
  ].obs;
  
  // Interests
  var selectedInterests = <String>[
    'Painting',
    'Content creation',
    'Camping'
  ].obs;
  
  // Basics
  var zodiac = 'Leo'.obs;
  var education2 = 'Bachelor'.obs;
  var job = 'UX/UI designer'.obs;
  var religion = 'Christian'.obs;
  
  // Lifestyle preferences
  var sleepingStyle = 'Night owl'.obs;
  var loveStyle = 'Thoughtful gesture'.obs;
  var weekend = 'Relaxing home'.obs;
  var travelling = 'Occasionally'.obs;
  var homeEnvironment = 'Quiet and calm'.obs;
  var livingSpace = 'Very organized'.obs;
  
  // Habits
  var communicationStyle = 'Good texter'.obs;
  var workout = 'Rarely'.obs;
  var eatingStyle = 'Balanced'.obs;
  var socialMedia = 'Frequently'.obs;
  var smokeOrDrink = 'Occasionally'.obs;
  var newExperiences = 'Sometimes'.obs;
  
  // Methods
  void updateProfileCompletion() {
    // Calculate completion based on filled fields
    int filledFields = 0;
    int totalFields = 20; // Approximate total fields
    
    if (name.value.isNotEmpty) filledFields++;
    if (aboutMe.value.isNotEmpty) filledFields++;
    if (photos.length >= 2) filledFields++;
    if (selectedTraits.length >= 3) filledFields++;
    if (selectedInterests.isNotEmpty) filledFields++;
    
    profileCompletion.value = ((filledFields / totalFields) * 100).round();
  }
  
  void addPhoto(String photoUrl) {
    if (photos.length < 6) {
      photos.add(photoUrl);
      updateProfileCompletion();
    }
  }
  
  void removePhoto(int index) {
    photos.removeAt(index);
    updateProfileCompletion();
  }
  
  void toggleTrait(String trait) {
    if (selectedTraits.contains(trait)) {
      selectedTraits.remove(trait);
    } else {
      selectedTraits.add(trait);
    }
  }
  
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }
  }
}
