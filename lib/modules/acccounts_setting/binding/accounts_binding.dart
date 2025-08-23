import 'package:get/get.dart';
import '../controller/intro_view_controller.dart';
import '../controller/gender_view_controller.dart';
import '../controller/choice_view_controller.dart';

class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntroViewController>(() => IntroViewController());
    Get.lazyPut<GenderViewController>(() => GenderViewController());
    Get.lazyPut<ChoiceViewController>(() => ChoiceViewController());
  }
}