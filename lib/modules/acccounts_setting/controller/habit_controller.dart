// import 'package:get/get.dart';

// class HabitController extends GetxController {
//   // Questions
//   final communicationStyles = ['Good texter', 'Bad texter', 'Video Chatter', 'Phone caller'];
//   final exerciseFrequencies = ['Yes', 'Several times a week', 'Rarely', 'Never'];
//   final foodPreferences = ['Healthy and balanced', 'Whatever I feel like', 'Specific diet', "I don't eat"];
//   final socialMediaUsage = ['Yes', 'Occasionally', 'Frequently', 'Rarely', 'Never'];
//   final smokingDrinking = ['Yes', 'Occasionally', 'No'];
//   final tryNewExperiences = ['Absolutely', 'Sometimes', 'Rarely', 'Never'];

//   // Selected indices
//   final selectedCommunicationStyle = Rxn<int>();
//   final selectedExerciseFrequency = Rxn<int>();
//   final selectedFoodPreference = Rxn<int>();
//   final selectedSocialMediaUsage = Rxn<int>();
//   final selectedSmokingDrinking = Rxn<int>();
//   final selectedTryNewExperiences = Rxn<int>();

//   // Toggle selections
//   void toggleCommunicationStyle(int index) => selectedCommunicationStyle.value = selectedCommunicationStyle.value == index ? null : index;
//   void toggleExerciseFrequency(int index) => selectedExerciseFrequency.value = selectedExerciseFrequency.value == index ? null : index;
//   void toggleFoodPreference(int index) => selectedFoodPreference.value = selectedFoodPreference.value == index ? null : index;
//   void toggleSocialMediaUsage(int index) => selectedSocialMediaUsage.value = selectedSocialMediaUsage.value == index ? null : index;
//   void toggleSmokingDrinking(int index) => selectedSmokingDrinking.value = selectedSmokingDrinking.value == index ? null : index;
//   void toggleTryNewExperiences(int index) => selectedTryNewExperiences.value = selectedTryNewExperiences.value == index ? null : index;

//   // Check completion
//   bool get isCompleted =>
//       selectedCommunicationStyle.value != null &&
//       selectedExerciseFrequency.value != null &&
//       selectedFoodPreference.value != null &&
//       selectedSocialMediaUsage.value != null &&
//       selectedSmokingDrinking.value != null &&
//       selectedTryNewExperiences.value != null;
// }
