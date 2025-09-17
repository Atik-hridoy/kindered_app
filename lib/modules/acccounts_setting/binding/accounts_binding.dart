import 'package:get/get.dart';
// import '../controller/intro_view_controller.dart';
// import '../controller/gender_view_controller.dart';
// import '../controller/choice_view_controller.dart';
// import '../controller/interest_view_controller.dart';
// import '../controller/habit_controller.dart';
// import '../controller/faith_belief_controller.dart';
// import '../controller/lifestyle_controller.dart';
// import '../controller/like_to_do_view_controller.dart';
// import '../controller/visual_story_controller.dart';
// import '../controller/inspire_controller.dart';
import '../controller/accounts_controller.dart';


class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<IntroViewController>(() => IntroViewController());
    // Get.lazyPut<GenderViewController>(() => GenderViewController());
    // Get.lazyPut<ChoiceViewController>(() => ChoiceViewController());
    // Get.lazyPut<InterestViewController>(() => InterestViewController());
    // Get.lazyPut<HabitController>(() => HabitController());
    // Get.lazyPut<FaithBeliefController>(() => FaithBeliefController());
    // Get.lazyPut<LifestyleController>(() => LifestyleController());
    // Get.lazyPut<LikeToDoController>(() => LikeToDoController());
    // Get.lazyPut<VisualStoryController>(() => VisualStoryController());
    // Get.lazyPut<InspireController>(() => InspireController());
    Get.lazyPut<AccountsController>(() => AccountsController());
  }
}