import 'package:get/get.dart';

class DisplayProfileController extends GetxController {
  // User profile data
  final RxString name = 'Kalvin'.obs;
  final RxInt age = 23.obs;
  final RxString location = '5 km away'.obs;
  final RxString bio = 'Digital creator & coffee enthusiast. Love hiking and photography. Let\'s connect!'.obs;
  final RxString jobTitle = 'Digital Creator'.obs;
  final RxString education = 'University of California'.obs;
  final RxString height = '5\' 8\''.obs;
  final RxString lookingFor = 'Friends & Dating'.obs;
  
  // User traits and interests
  final RxList<String> traits = <String>[
    'Adventurous',
    'Creative',
    'Optimistic',
    'Ambitious',
  ].obs;
  
  final RxList<String> interests = <String>[
    'Photography',
    'Hiking',
    'Coffee',
    'Travel',
    'Music',
  ].obs;
  
  // Gallery images
  final RxList<String> galleryImages = <String>[
    'assets/images/ob1.jpg',
    'assets/images/ob2.jpg',
    'assets/images/au1.jpg',
  ].obs;
  
  // Social media links
  final RxString instagram = '@kalvin_doe'.obs;
  final RxString twitter = '@kalvindoe'.obs;
  
  // Methods to update profile data
  void updateBasicInfo({String? name, int? age, String? location}) {
    if (name != null) this.name.value = name;
    if (age != null) this.age.value = age;
    if (location != null) this.location.value = location;
  }
  
  void updateBio(String newBio) {
    bio.value = newBio;
  }
  
  void addTrait(String trait) {
    if (!traits.contains(trait)) {
      traits.add(trait);
    }
  }
  
  void removeTrait(String trait) {
    traits.remove(trait);
  }
  
  void addInterest(String interest) {
    if (!interests.contains(interest)) {
      interests.add(interest);
    }
  }
  
  void removeInterest(String interest) {
    interests.remove(interest);
  }
  
  void addGalleryImage(String imagePath) {
    galleryImages.add(imagePath);
  }
  
  void removeGalleryImage(int index) {
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
    }
  }
}