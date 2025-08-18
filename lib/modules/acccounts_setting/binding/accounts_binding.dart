import 'package:get/get.dart';
import '../controller/intro_view_controller.dart';

class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IntroViewController>(() => IntroViewController());
  }
}
