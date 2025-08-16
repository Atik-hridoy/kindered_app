import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'config/app_routes.dart';
import 'config/app_themes.dart';
import 'modules/splash/splash_view.dart';
import 'modules/onboarding/onboarding_view.dart';
import 'modules/splash/splash_binding.dart';
import 'modules/onboarding/onboarding_binding.dart';
import 'modules/auth/views/login_view.dart';
import 'modules/auth/bindings/auth_binding.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kindred App',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(
          name: AppRoutes.splash,
          page: () => const SplashView(),
          binding: SplashBinding(),
        ),
        GetPage(
          name: AppRoutes.onboarding,
          page: () => OnboardingView(),
          binding: OnboardingBinding(),
        ),
        GetPage(
          name: AppRoutes.login,
          page: () => const LoginView(),
          binding: AuthBinding(),
        ),
      ],
      defaultTransition: Transition.fade,
    );
  }
}
