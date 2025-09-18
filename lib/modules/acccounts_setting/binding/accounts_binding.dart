import 'package:get/get.dart';
import 'package:kindered_app/local/storage_service.dart';
import '../controller/accounts_controller.dart';


class AccountsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccountsController>(() {
      final c = AccountsController();
      if (LocalStorage.token.isNotEmpty) {
        c.initializeAccountSetupService(LocalStorage.token);
      }
      return c;
    }, fenix: true);
  }
}