import 'package:get/get.dart';
import 'package:kindered_app/modules/acccounts_setting/binding/accounts_binding.dart';
import 'package:kindered_app/modules/acccounts_setting/view/gender_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/intro_view.dart';
import 'package:kindered_app/modules/auth/views/create_account_view.dart';
import 'package:kindered_app/modules/auth/views/extended_login_view.dart';
import 'package:kindered_app/modules/auth/views/otp_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/auth_binding.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String extendedLogin = '/extended-login';
  static const String createAccount = '/create-account';
  static const String otp = '/otp';
  static const String intro = '/intro';
  static const String gender = '/gender';
  // Route getters
  static String getSplashRoute() => splash;
  static String getOnboardingRoute() => onboarding;
  static String getLoginRoute() => login;
  static String getExtendedLoginRoute() => extendedLogin;
  static String getCreateAccountRoute() => createAccount;
  static String getOtpRoute() => otp;
  static String getIntroRoute() => intro;
  // Route definitions
  static final List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: extendedLogin,
      page: () => const ExtendedLoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: onboarding,
      page: () => OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: createAccount,
      page: () => const CreateAccountView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: otp,
      page: () => const OtpView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: intro,
      page: () => IntroView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: gender,
      page: () => GenderView(),
      binding: AccountsBinding(),
    ),
    ];
    
}
