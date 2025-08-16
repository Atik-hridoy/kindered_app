import 'package:get/get.dart';
import 'package:kindered_app/modules/auth/controllers/create_account_view_controller.dart';
import '../controllers/login_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(() => LoginController());
    Get.lazyPut<CreateAccountViewController>(() => CreateAccountViewController());
  }
}
