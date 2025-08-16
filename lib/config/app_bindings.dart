import 'package:get/get.dart';
import '../modules/onboarding/onboarding_controller.dart';
import '../modules/splash/splash_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(() => SplashController());
    Get.lazyPut<OnboardingController>(() => OnboardingController());
  }
}
