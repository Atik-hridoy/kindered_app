import 'package:get/get.dart';
import 'package:kindered_app/modules/acccounts_setting/binding/accounts_binding.dart';
import 'package:kindered_app/modules/acccounts_setting/view/education_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/faith_belief_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/habit_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/lifestyle_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/gender_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/inspire_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/height_weight_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/intro_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/choice_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/interest_view.dart';
import 'package:kindered_app/modules/auth/views/create_account_view.dart';
import 'package:kindered_app/modules/auth/views/extended_login_view.dart';
import 'package:kindered_app/modules/auth/views/otp_view.dart';
import 'package:kindered_app/modules/home/bindings.dart';
import 'package:kindered_app/modules/location/bindings.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import 'package:kindered_app/modules/acccounts_setting/view/like_to_do_view.dart';
import 'package:kindered_app/modules/acccounts_setting/view/visual_story.dart';
import 'package:kindered_app/modules/location/location_view.dart';
import 'package:kindered_app/modules/home/home_suggestion_view.dart';




class AppRoutes {
  // Route names
  static const String dev = '/dev';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String extendedLogin = '/extended-login';
  static const String createAccount = '/create-account';
  static const String otp = '/otp';
  static const String intro = '/intro';
  static const String gender = '/gender';
  static const String choice = '/choice';
  static const String interest = '/interest';
  static const String heightWeight = '/height_weight';
  static const String educationView = '/education_view';
  static const String inspireView = '/inspire_view';
  static const String faithBeliefView = '/faith_belief_view';
  static const String lifestyleView = '/lifestyle_view';
  static const String habitView = '/habit_view';
  static const String likeToDoView = '/like_to_do_view';
  static const String visualStoryView = '/visual_story_view';
  static const String locationView = '/location_view';
  static const String homeSuggestionView = '/home_suggestion_view';
  
  static String getSplashRoute() => splash;
  static String getOnboardingRoute() => onboarding;
  static String getLoginRoute() => login;
  static String getExtendedLoginRoute() => extendedLogin;
  static String getCreateAccountRoute() => createAccount;
  static String getOtpRoute() => otp;
  static String getIntroRoute() => intro;
  static String getGenderRoute() => gender;
  static String getChoiceRoute() => choice;
  static String getInterestRoute() => interest;
  static String getHeightWeightRoute() => heightWeight;
  static String getEducationViewRoute() => educationView;
  static String getInspireViewRoute() => inspireView;
  static String getFaithBeliefViewRoute() => faithBeliefView;
  static String getLifestyleViewRoute() => lifestyleView;
  static String getHabitViewRoute() => habitView;  
  static String getLikeToDoViewRoute() => likeToDoView;
  static String getVisualStoryViewRoute() => visualStoryView;
  static String getLocationViewRoute() => locationView;
  static String getHomeSuggestionViewRoute() => homeSuggestionView;
  
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
      name:AppRoutes.otp,
      page: () => const OtpView(),
      // binding: AuthBinding(),
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
    GetPage(
      name: choice,
      page: () => ChoiceView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: interest,
      page: () => InterestView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: heightWeight,
      page: () => HeightWeightView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: educationView,
      page: () => EducationView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: inspireView,
      page: () => InspireView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: faithBeliefView,
      page: () => FaithBeliefView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: lifestyleView,
      page: () => const LifestyleView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: habitView,
      page: () => const HabitView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: likeToDoView,
      page: () => const LikeToDoView(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: visualStoryView,
      page: () => const VisualStory(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: locationView,
      page: () => const LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: homeSuggestionView,
      page: () => const HomeSuggestionView(),
      binding: HomeBinding(),
    ),
  ];
}
