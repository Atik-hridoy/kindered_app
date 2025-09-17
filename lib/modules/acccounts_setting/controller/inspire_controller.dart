// import 'package:get/get.dart';

// class InspireController extends GetxController {
//   final traits = [
//     'Ambition',
//     'Emotional intelligence',
//     'Curiosity',
//     'Humble',
//     'Witty',
//     'Loyal',
//     'Kind',
//     'Humour',
//   ];

//   // Reactive set for selected indices
//   final RxSet<int> selectedIndices = <int>{}.obs;

//   // Toggle selection
//   void toggleTrait(int index) {
//     if (selectedIndices.contains(index)) {
//       selectedIndices.remove(index);
//     } else {
//       selectedIndices.add(index);
//     }
//   }

//   // Minimum selection check
//   bool get isButtonEnabled => selectedIndices.length >= 3;

//   // Remaining selection count
//   int get remainingSelections => selectedIndices.length < 3 ? 3 - selectedIndices.length : 0;
// }
