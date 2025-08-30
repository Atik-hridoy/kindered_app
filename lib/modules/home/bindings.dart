


import 'package:get/get.dart';
import 'package:kindered_app/modules/home/controller/home_suggestion_controller.dart';
import 'package:kindered_app/modules/home/controller/ai_assistent_controller.dart';
import 'package:kindered_app/modules/home/controller/message_controller.dart';



class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeSuggestionController>(() => HomeSuggestionController());
    Get.lazyPut<AiAssistentController>(() => AiAssistentController());
    Get.lazyPut<MessageController>(() => MessageController());
  }
}
