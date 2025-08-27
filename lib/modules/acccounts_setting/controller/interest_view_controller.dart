import 'package:get/get.dart';

class InterestViewController extends GetxController {
  // Reactive list to track selected indices
  final selectedIndices = <int>[].obs;
  
  // Toggle selection of an index
  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }
}
