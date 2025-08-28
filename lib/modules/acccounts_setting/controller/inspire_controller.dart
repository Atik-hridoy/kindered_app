import 'package:get/get.dart';

/// Controller for managing the inspire/interest selection screen
/// 
/// This controller can be used to handle business logic related to interest
/// selection, API calls, and state management when needed in the future.
class InspireController extends GetxController {
  // Reactive state for selected interests
  final RxList<String> selectedInterests = <String>[].obs;
  
  // List of available interests
 

  // Toggle selection of an interest
  void toggleInterest(String interest) {
    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else if (selectedInterests.length < 5) {
      selectedInterests.add(interest);
    }
  }

  // Check if the minimum selection requirement is met
  bool get hasMinimumSelections => selectedInterests.length >= 3;
  
  // For future use: Save selected interests to backend
  Future<void> saveInterests() async {
    // Implementation for saving to backend will go here
  }
  
  @override
  void onClose() {
    selectedInterests.close();
    super.onClose();
  }
}
