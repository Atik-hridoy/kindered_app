import 'package:get/get.dart';

class InterestViewController extends GetxController {
  /// Interest options stored in the controller (titles and descriptions).
  final List<Map<String, String>> interestOptions = const [
    {
      'title': 'Long-term partner',
      'description':
          'Building a deep, lasting relationship with shared dreams, trust, and emotional connection'
    },
    {
      'title': 'Casual Connection',
      'description':
          'Keeping things light, fun, and exciting while exploring new people and experiences'
    },
    {
      'title': 'BFF',
      'description':
          'Creating a supportive and joyful bond based on trust, laughter, and shared interests'
    },
  ];

  /// Reactive list to track selected indices.
  final RxList<int> selectedIndices = <int>[].obs;

  /// Toggle selection of an index.
  void toggleSelection(int index) {
    if (selectedIndices.contains(index)) {
      selectedIndices.remove(index);
    } else {
      selectedIndices.add(index);
    }
  }

  /// Validate if at least one interest is selected.
  String? validateSelections() {
    if (selectedIndices.isEmpty) {
      return 'Please select at least one interest.';
    }
    return null;
  }
}
