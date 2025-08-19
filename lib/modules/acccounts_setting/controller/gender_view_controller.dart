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
  Future<void> updateProfile() async {
    try {
      final validationError = validateGender();
      if (validationError != null) {
        Get.snackbar(
          'Validation Error',
          validationError,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      isLoading.value = true;
      
      // Here you would typically call your API to update the user's gender
      await Future.delayed(const Duration(seconds: 1));
      
      // For demonstration, show success message
      Get.snackbar(
        'Success',
        'Gender updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      
      // Navigate to next screen after successful update
      // Get.to(() => NextScreen());
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update gender: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

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
