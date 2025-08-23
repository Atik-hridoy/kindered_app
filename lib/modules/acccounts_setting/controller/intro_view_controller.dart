import 'package:get/get.dart';

class IntroViewController extends GetxController {
  // State variables
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString age = ''.obs;
  final RxBool showOnProfile = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProfileVisible = true.obs;

  // Update profile
  void updateProfile() async {
    try {
      isLoading.value = true;
      // Simulating API call for updating profile
      await Future.delayed(const Duration(seconds: 2));

      // Handle profile update logic here, for example, saving to an API or local storage
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load user data (Simulated here)
  void loadUserData() {
    // You can replace this with actual data fetching logic from API or storage
    firstName.value = 'Alex'; // Example of pre-filled data
    lastName.value = 'Smith'; // Example of pre-filled data
    age.value = '23';         // Example of pre-filled data
    showOnProfile.value = true;  // Example of pre-filled toggle state
  }

  // Handle initialization
  @override
  void onInit() {
    super.onInit();
    loadUserData(); // Load user data when the controller initializes
  }

  // Handle logic when the user presses the "Next" button
  void onNextPressed() {
    if (firstName.value.isEmpty || lastName.value.isEmpty || age.value.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please complete the form before proceeding.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Call updateProfile function or navigate based on the business logic
    updateProfile();
  }

  // Toggle profile visibility
  void toggleProfileVisibility() {
    isProfileVisible.toggle();
  }
}
