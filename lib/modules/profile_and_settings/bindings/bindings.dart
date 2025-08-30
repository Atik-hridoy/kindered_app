



import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/account_setting_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/display_profile_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/number_verify_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/update_phon_number_controller.dart';




class ProfileAndStettings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAndStettings>(() => ProfileAndStettings());
    Get.lazyPut<AccountSettingController>(() => AccountSettingController());
    Get.lazyPut<UpdatePhonNumberController>(() => UpdatePhonNumberController());
    Get.lazyPut<NumberVerifyController>(() => NumberVerifyController());
    Get.lazyPut<DisplayProfileController>(() => DisplayProfileController());
  }
}
