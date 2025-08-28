import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/modules/acccounts_setting/binding/accounts_binding.dart';
import 'package:kindered_app/modules/acccounts_setting/view/choice_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/education_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/faith_belief_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/gender_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/height_weight_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/inspire_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/interest_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/intro_view.dart';
import 'package:kindered_app/modules/auth/views/create_account_view.dart';
import 'package:kindered_app/modules/auth/views/otp_view.dart';
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
        GetPage(
          name: AppRoutes.createAccount,
          page: () => const CreateAccountView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.otp,
          page: () =>  OtpView(),
          binding: AuthBinding(),
        ),
        GetPage(
          name: AppRoutes.intro,
          page: () => IntroView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.gender,
          page: () => GenderView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.choice,
          page: () => ChoiceView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.interest,
          page: () => InterestView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.heightWeight,
          page: () => HeightWeightView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.educationView,
          page: () => EducationView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.inspireView,
          page: () => InspireView(),
          binding: AccountsBinding(),
        ),
        GetPage(
          name: AppRoutes.faithBeliefView,
          page: () => FaithBeliefView(),
          binding: AccountsBinding(),
        ),
      ],
      defaultTransition: Transition.fade,
    );
  }
}
