import 'package:get/get.dart';

class LifestyleController extends GetxController {
  // Question 1: Morning or Night person
  final selectedDayPreference = Rxn<int>();
  final List<String> dayPreferences = [
    'Morning Person',
    'Night Owl',
    'In Between',
    'Depends on the day'
  ];

  // Question 2: Love language
  final selectedLoveLanguage = Rxn<int>();
  final List<String> loveLanguages = [
    'Words of Affirmation',
    'Quality Time',
    'Receiving Gifts',
    'Acts of Service',
    'Physical Touch'
  ];

  // Question 3: Weekend preferences
  final selectedWeekendActivity = Rxn<int>();
  final List<String> weekendActivities = [
    'Relaxing at home',
    'Going out with friends',
    'Exploring new places',
    'Pursuing hobbies',
    'Catching up on work/errands'
  ];

  // Question 4: Travel preference
  final selectedTravelPreference = Rxn<int>();
  final List<String> travelPreferences = [
    'Love traveling',
    'Like it occasionally',
    'Prefer staying local',
    'Depends on the destination'
  ];

  // Toggle selection methods for each question
  void toggleDayPreference(int index) {
    selectedDayPreference.value = selectedDayPreference.value == index ? null : index;
    update();
  }

  void toggleLoveLanguage(int index) {
    selectedLoveLanguage.value = selectedLoveLanguage.value == index ? null : index;
    update();
  }

  void toggleWeekendActivity(int index) {
    selectedWeekendActivity.value = selectedWeekendActivity.value == index ? null : index;
    update();
  }

  void toggleTravelPreference(int index) {
    selectedTravelPreference.value = selectedTravelPreference.value == index ? null : index;
    update();
  }

  // Check if all questions are answered
  bool get isCompleted => 
      selectedDayPreference.value != null &&
      selectedLoveLanguage.value != null &&
      selectedWeekendActivity.value != null &&
      selectedTravelPreference.value != null;
}
