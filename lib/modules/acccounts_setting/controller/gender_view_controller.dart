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
    if (selectedGender.value.isEmpty) {
      return 'Please select your gender';
    }
    return null;
  }

  // Simulate profile update or API call
  Future<void> updateProfile() async {
    if (!isGenderSelected) return;
    try {
      isLoading.value = true;
      await Future.delayed(const Duration(seconds: 1)); // Simulated network delay
      // Add your API call here using Dio or any service.
    } catch (e) {
      // Handle error properly (logging or showing a message)
    } finally {
      isLoading.value = false;
    }
  }

  // Load user's current gender (e.g., from API or cache)
  void loadUserGender() {
    // Example: selectedGender.value = "Man";
  }

  @override
  void onInit() {
    super.onInit();
    loadUserGender();
  }
}
