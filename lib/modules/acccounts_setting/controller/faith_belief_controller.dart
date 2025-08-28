import 'package:get/get.dart';

class FaithBeliefController extends GetxController {
  // Religion section
  final selectedReligion = Rxn<int>();
  final List<String> religions = [
    'Agnostic',
    'Atheist',
    'Buddhist',
    'Christian',
    'Hindu',
    'Jewish',
    'Muslim',
    'Sikh',
    'Spiritual',
    'Prefer not to say'
  ];

  // Zodiac signs section
  final selectedZodiac = Rxn<int>();
  final List<String> zodiacSigns = [
    'Aries',
    'Taurus',
    'Gemini',
    'Cancer',
    'Leo',
    'Virgo',
    'Libra',
    'Scorpio',
    'Sagittarius',
    'Capricorn',
    'Aquarius',
    'Pisces',
    'Not sure',
    'Prefer not to say'
  ];

  // Check if both selections are made
  bool get isCompleted => selectedReligion.value != null && selectedZodiac.value != null;

  // Toggle religion selection
  void toggleReligion(int index) {
    selectedReligion.value = selectedReligion.value == index ? null : index;
    update(); // Notify listeners to rebuild UI
  }

  // Toggle zodiac selection
  void toggleZodiac(int index) {
    selectedZodiac.value = selectedZodiac.value == index ? null : index;
    update(); // Notify listeners to rebuild UI
  }

  // Get selected religion
  String? get selectedReligionText => 
      selectedReligion.value != null ? religions[selectedReligion.value!] : null;

  // Get selected zodiac
  String? get selectedZodiacText => 
      selectedZodiac.value != null ? zodiacSigns[selectedZodiac.value!] : null;
}
