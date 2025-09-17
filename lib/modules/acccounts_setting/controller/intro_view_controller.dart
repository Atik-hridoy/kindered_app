// import 'package:get/get.dart';
// import 'package:kindered_app/config/app_routes.dart';

// class IntroViewController extends GetxController {
//   final RxString firstName = ''.obs;
//   final RxString lastName = ''.obs;
//   final RxString age = ''.obs;
//   final RxBool isLoading = false.obs;

//   void updateFirstName(String value) => firstName.value = value;
//   void updateLastName(String value) => lastName.value = value;
//   void updateAge(String value) => age.value = value;

//   void updateProfile() async {
//     try {
//       isLoading.value = true;
//       await Future.delayed(const Duration(seconds: 2));
//       // Place API call or local storage update here
//     } catch (e) {
//       Get.snackbar('Error', 'Failed to update profile: $e',
//           snackPosition: SnackPosition.BOTTOM);
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void loadUserData() {
//     firstName.value = 'Alex';
//     lastName.value = 'Smith';
//     age.value = '23';
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     loadUserData();
//   }

//   void onNextPressed() {
//     if (firstName.value.isEmpty || lastName.value.isEmpty || age.value.isEmpty) {
//       Get.snackbar('Validation Error', 'Please complete the form before proceeding.',
//           snackPosition: SnackPosition.BOTTOM);
//       return;
//     }
//     updateProfile();
//     Get.offAllNamed(AppRoutes.gender);
//   }
// }
