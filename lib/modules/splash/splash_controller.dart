import 'dart:developer';
import 'package:get/get.dart';
import 'package:kindered_app/modules/onboarding/onboarding_view.dart';
import '../../config/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    log('SplashController: onInit() called');
  }

  @override
  void onReady() {
    super.onReady();
    log('SplashController: onReady() called');
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    log('SplashController: Starting navigation to onboarding');
    
    // Add a small delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Log current route before navigation
    log('SplashController: Current route before navigation: ${Get.currentRoute}');
    
    try {
      log('SplashController: Navigating to ${AppRoutes.onboarding}');
      Get.offAllNamed(AppRoutes.onboarding);
      log('SplashController: Navigation complete');
    } catch (e, stackTrace) {
      log('SplashController: Error during navigation', error: e, stackTrace: stackTrace);
      // Fallback to direct navigation if named route fails
      Get.offAll(() => const OnboardingView());
    }
  }
}