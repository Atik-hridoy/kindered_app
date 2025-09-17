// import 'package:get/get.dart';

// class FaithBeliefController extends GetxController {
//   // Religion selection
//   final religions = [
//     'Agnostic', 'Atheist', 'Buddhist', 'Christian', 'Hindu',
//     'Jewish', 'Muslim', 'Sikh', 'Spiritual', 'Prefer not to say',
//   ];
//   final selectedReligionIndex = Rxn<int>();

//   // Zodiac selection
//   final zodiacSigns = [
//     'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo', 
//     'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 
//     'Pisces', 'Not sure', 'Prefer not to say',
//   ];
//   final selectedZodiacIndex = Rxn<int>();

//   // Toggle religion
//   void toggleReligion(int index) {
//     selectedReligionIndex.value = selectedReligionIndex.value == index ? null : index;
//   }

//   // Toggle zodiac
//   void toggleZodiac(int index) {
//     selectedZodiacIndex.value = selectedZodiacIndex.value == index ? null : index;
//   }

//   // Check if both selections are made
//   bool get isCompleted =>
//       selectedReligionIndex.value != null && selectedZodiacIndex.value != null;

//   // Get selected values
//   String? get selectedReligion =>
//       selectedReligionIndex.value != null ? religions[selectedReligionIndex.value!] : null;
//   String? get selectedZodiac =>
//       selectedZodiacIndex.value != null ? zodiacSigns[selectedZodiacIndex.value!] : null;
// }
