import 'package:get/get.dart';

class ChoiceViewController extends GetxController {
  // Observable variable to track the selected option
  final RxString selectedOption = ''.obs;

  // Method to update the selected option
  void selectOption(String option) {
    selectedOption.value = option;
  }

  // Method to check if an option is selected
  bool isOptionSelected(String option) {
    return selectedOption.value == option;
  }

  // Method to clear selection
  void clearSelection() {
    selectedOption.value = '';
  }

  // Method to validate if an option is selected
  bool get hasSelectedOption => selectedOption.isNotEmpty;
}