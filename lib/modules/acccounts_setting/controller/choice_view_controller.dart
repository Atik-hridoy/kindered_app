// import 'package:get/get.dart';

// class ChoiceViewController extends GetxController {
//   /// Observable list for multiple selections
//   final RxList<String> selectedGenders = <String>[].obs;

//   /// Toggle a gender in the selection list
//   void toggleGender(String gender) {
//     if (selectedGenders.contains(gender)) {
//       selectedGenders.remove(gender);
//     } else {
//       selectedGenders.add(gender);
//     }
//   }

//   /// Check if a gender is selected
//   bool isGenderSelected(String gender) => selectedGenders.contains(gender);

//   /// Clear all selections
//   void clearSelections() => selectedGenders.clear();

//   /// Validate selections
//   String? validateSelections() {
//     if (selectedGenders.isEmpty) {
//       return 'Please select at least one option.';
//     }
//     return null;
//   }
// }
