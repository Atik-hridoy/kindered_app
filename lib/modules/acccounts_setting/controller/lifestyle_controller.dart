// import 'package:get/get.dart';

// class LifestyleController extends GetxController {
//   // Question 1: Morning/Night person
//   final dayPreferences = ['Morning Person', 'Night Owl', 'In Between', 'Depends on the day'];
//   final selectedDayPreference = Rxn<int>();

//   // Question 2: Love language
//   final loveLanguages = ['Words of Affirmation', 'Quality Time', 'Receiving Gifts', 'Acts of Service', 'Physical Touch'];
//   final selectedLoveLanguage = Rxn<int>();

//   // Question 3: Weekend preferences
//   final weekendActivities = ['Relaxing at home', 'Going out with friends', 'Exploring new places', 'Pursuing hobbies', 'Catching up on work/errands'];
//   final selectedWeekendActivity = Rxn<int>();

//   // Question 4: Travel preference
//   final travelPreferences = ['Love traveling', 'Like it occasionally', 'Prefer staying local', 'Depends on the destination'];
//   final selectedTravelPreference = Rxn<int>();

//   // Toggle selections
//   void toggleDayPreference(int index) => selectedDayPreference.value = selectedDayPreference.value == index ? null : index;
//   void toggleLoveLanguage(int index) => selectedLoveLanguage.value = selectedLoveLanguage.value == index ? null : index;
//   void toggleWeekendActivity(int index) => selectedWeekendActivity.value = selectedWeekendActivity.value == index ? null : index;
//   void toggleTravelPreference(int index) => selectedTravelPreference.value = selectedTravelPreference.value == index ? null : index;

//   // Check if all questions are answered
//   bool get isCompleted =>
//       selectedDayPreference.value != null &&
//       selectedLoveLanguage.value != null &&
//       selectedWeekendActivity.value != null &&
//       selectedTravelPreference.value != null;
// }
