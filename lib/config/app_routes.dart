import 'package:get/get.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_binding.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  
  // Route getters
  static String getSplashRoute() => splash;
  static String getOnboardingRoute() => onboarding;
  static String getHomeRoute() => home;
  
  // Route definitions
  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
  ];
}
