


import 'package:get/get.dart';
import 'package:kindered_app/modules/home/home_suggestion_controller.dart';



class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeSuggestionController>(() => HomeSuggestionController());
  }
}


