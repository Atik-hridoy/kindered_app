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
import 'package:kindered_app/modules/auth/views/login_with_email.dart';
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
import 'package:kindered_app/modules/home/view/home_suggestion_view.dart';
import 'package:kindered_app/modules/home/view/ai_assistent_view.dart';
import 'package:kindered_app/modules/profile_and_settings/view/profile_view.dart';
import 'package:kindered_app/modules/profile_and_settings/view/account_setting.dart';
import 'package:kindered_app/modules/profile_and_settings/bindings/bindings.dart';
import 'package:kindered_app/modules/profile_and_settings/view/update_phon_number_view.dart';
import 'package:kindered_app/modules/profile_and_settings/view/number_verify_view.dart';
import 'package:kindered_app/modules/home/view/message_view.dart';
import 'package:kindered_app/modules/home/view/chat_view.dart';
import 'package:kindered_app/modules/profile_and_settings/view/display_profile.dart';
import 'package:kindered_app/modules/profile_and_settings/view/about_us.dart';
import 'package:kindered_app/modules/profile_and_settings/view/help_support.dart';
import 'package:kindered_app/modules/profile_and_settings/view/terms_condition.dart';
import 'package:kindered_app/modules/location/location_view.dart' as location_module;
import 'package:kindered_app/modules/profile_and_settings/view/edit_profile.dart';

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
  static const String homeSuggestionView = '/home-suggestion';
  static const String aiAssistantView = '/ai-assistant';
  static const String profileView = '/profile_view';
  static const String accountSettingView = '/account_setting_view';
  static const String updatePhonNumberView = '/update_phon_number_view';
  static const String numberVerifyView = '/number_verify_view';
  static const String messageView = '/message_view';
  static const String chat = '/chat';
  static const String displayProfile = '/display-profile_view';
  static const String editProfile = '/edit-profile_view';
  static const String termsConditionView = '/terms_condition_view';
  static const String newLocationView = '/new_location_view';
  static const String aboutUsView = '/about_us_view';
  static const String helpSupportView = '/help-support';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String loginWithEmail = '/login-with-email';

  // Route getters

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
  static String getAiAssistantViewRoute() => aiAssistantView; // Added getter method
  static String getProfileViewRoute() => profileView;
  static String getAccountSettingViewRoute() => accountSettingView;
  static String getUpdatePhonNumberViewRoute() => updatePhonNumberView;
  static String getNumberVerifyViewRoute() => numberVerifyView;
  static String getMessageViewRoute() => messageView;
  static String getChatViewRoute() => chat;
  static String getDisplayProfileRoute() => displayProfile;
  static String getEditProfileRoute() => editProfile;
  static String getTermsConditionViewRoute() => termsConditionView;
  static String getNewLocationViewRoute() => newLocationView;
  static String getAboutUsViewRoute() => aboutUsView;
  static String getHelpSupportViewRoute() => helpSupportView;

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
      page: () => VisualStory(),
      binding: AccountsBinding(),
    ),
    GetPage(
      name: locationView,
      page: () => const location_module.LocationView(),
      binding: LocationBinding(),
    ),
    GetPage(
      name: homeSuggestionView,
      page: () => const HomeSuggestionView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: aiAssistantView,
      page: () => const AiAssistantView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: profileView,
      page: () => ProfileView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: accountSettingView,
      page: () => const AccountSettingView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: updatePhonNumberView,
      page: () => const UpdatePhonNumberView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: numberVerifyView,
      page: () => const NumberVerifyView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: messageView,
      page: () => const MessageView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: displayProfile,
      page: () => const DisplayProfileView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: chat,
      page: () => const ChatConversationView(),
      binding: HomeBinding(),
    ),
   
    GetPage(
      name: termsAndConditions,
      page: () => const TermsAndConditions(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: newLocationView,
      page: () => const LocationView(),
      binding: ProfileAndStettings(),
    ),
    
    GetPage(
      name: aboutUsView,
      page: () => const AboutUsView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: helpSupportView,
      page: () => const HelpSupportView(),
      binding: ProfileAndStettings(),
    ),
    GetPage(
      name: loginWithEmail,
      page: () => const LoginWithEmail(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: editProfile,
      page: () => EditProfile(),
      binding: ProfileAndStettings(),
    ),
  ];
}