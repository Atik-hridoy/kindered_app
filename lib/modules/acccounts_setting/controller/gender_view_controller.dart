import 'package:get/get.dart';

class GenderViewController extends GetxController {
  // Gender selection state
  final RxString selectedGender = ''.obs;
  final RxBool isLoading = false.obs;

  // Check if a gender is selected
  bool get isGenderSelected => selectedGender.value.isNotEmpty;

  // Update selected gender
  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  // Validate gender selection
  String? validateGender() {
    if (selectedGender.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  // Update profile with selected gender
  


  // Load user's current gender (if any)
  void loadUserGender() {
    // You can replace this with actual data fetching logic
    // For example: selectedGender.value = userData.gender;
  }

  @override
  void onInit() {
    super.onInit();
    loadUserGender();
  }
}
