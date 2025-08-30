



import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/account_setting_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/profile_view_controller.dart';




class ProfileAndStettings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAndStettings>(() => ProfileAndStettings());
    Get.lazyPut<AccountSettingController>(() => AccountSettingController());
  }
}
