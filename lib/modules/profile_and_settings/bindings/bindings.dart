



import 'package:get/get.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/about_us_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/account_setting_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/display_profile_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/edit_profile_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/help_support_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/location_view_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/number_verify_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/terms_condition_controller.dart';
import 'package:kindered_app/modules/profile_and_settings/controller/update_phon_number_controller.dart';




class ProfileAndStettings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileAndStettings>(() => ProfileAndStettings());
    Get.lazyPut<AccountSettingController>(() => AccountSettingController());
    Get.lazyPut<UpdatePhonNumberController>(() => UpdatePhonNumberController());
    Get.lazyPut<NumberVerifyController>(() => NumberVerifyController());
    Get.lazyPut<DisplayProfileController>(() => DisplayProfileController());
    Get.lazyPut<ProfileEditController>(() => ProfileEditController());
    Get.lazyPut<TermsAndConditionsController>(() => TermsAndConditionsController());
    Get.lazyPut<LocationViewController>(() => LocationViewController());
    Get.lazyPut<AboutUsController>(() => AboutUsController());
    Get.lazyPut<HelpSupportController>(() => HelpSupportController());
  }
}
