import 'package:get/get.dart';

class AppStrings extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Common
          'appName': 'Kindred App',
          'next': 'Next',
          'back': 'Back',
          'save': 'Save',
          'cancel': 'Cancel',
          'error': 'Error',
          'success': 'Success',
          'continueText': 'Continue',
          'phoneNumberTitle': 'Can we get your phone number',
          'please': 'Please?',
          'enterPhoneNumber': 'Enter phone number',
          'phoneVerificationMessage': 'We will send you a verification code to verify your phone number.',
          'verifyYourNumber': 'We need to verify your number',
          'enterVerificationCode': 'Please enter the verification code sent to',
          'sentTo': 'Sent to',
          'resendCodePrompt': "Didn't receive the code? ",
          'resend': 'Resend',
          'verify': 'Verify',
          'verifyYourEmail': 'Verify Your Email',
          'enterOtp': 'Enter the 4-digit code sent to',
          'resendCode': 'Resend Code',
          'didntReceiveCode': "Didn't receive a code?",
          'male': 'Male',
          'female': 'Female',
          'other': 'Other',
          'preferNotToSay': 'Prefer not to say',
          'whatsYourGender': "What's your gender?",
          'selectYourGender': 'Select your gender',
          'letsStartWithIntro': "Let's start with an Intro",
          'yourFirstName': 'Your first name',
          'yourAge': 'Your age',
          'showOnProfile': 'Show on profile',
          
          // Gender Selection
          'selectGender': 'Select Your Gender',
          
          // Validation
          'fieldRequired': 'This field is required',
          'invalidEmail': 'Please enter a valid email',
          'passwordTooShort': 'password Too Short',
          'passwordsDontMatch': 'passwords Dont Match',
        },
        'bn_BD': {
          // Common
          'appName': 'কিনড্রেড অ্যাপ',
          'next': 'পরবর্তী',
          'back': 'পিছনে',
          'save': 'সংরক্ষণ',
          'cancel': 'বাতিল',
          'error': 'ত্রুটি',
          'success': 'সফল',
          'continueText': 'চালিয়ে যান',
          'phoneNumberTitle': 'আমাদের আপনার ফোন নম্বর দিন',
          'please': 'দয়া করে?',
          'enterPhoneNumber': 'ফোন নম্বর লিখুন',
          'phoneVerificationMessage': 'আমরা আপনার ফোন নম্বর যাচাই করার জন্য একটি কোড পাঠাবো।',
          'verifyYourNumber': 'আপনার নম্বরটি যাচাই করা প্রয়োজন',
          'enterVerificationCode': 'অনুগ্রহ করে প্রেরিত যাচাইকরণ কোডটি লিখুন',
          'sentTo': 'পাঠানো হয়েছে',
          'resendCodePrompt': 'কোড পাননি? ',
          'resend': 'পুনরায় পাঠান',
          'verify': 'যাচাই করুন',
          'verifyYourEmail': 'আপনার ইমেইল যাচাই করুন',
          'enterOtp': 'পাঠানো ৬-অঙ্কের কোডটি লিখুন',
          'resendCode': 'কোড পুনরায় পাঠান',
          'didntReceiveCode': 'কোড পেলেন না?',
          'male': 'পুরুষ',
          'female': 'মহিলা',
          'other': 'অন্যান্য',
          'preferNotToSay': 'বলতে চাই না',
          'whatsYourGender': 'আপনার লিঙ্গ কি?',
          'selectYourGender': 'আপনার লিঙ্গ নির্বাচন করুন',
          'letsStartWithIntro': 'চলুন শুরু করি একটি ভূমিকা দিয়ে',
          'yourFirstName': 'আপনার প্রথম নাম',
          'yourAge': 'আপনার বয়স',
          'showOnProfile': 'প্রোফাইলে দেখান',
          
          // Gender Selection
          
          'whichGenderDescribeYouTheBest': 'Which gender describe you the best?',
          
          // Validation
          'fieldRequired': 'এই ফিল্ডটি প্রয়োজন',
          'invalidEmail': 'সঠিক ইমেইল দিন',
        },
      };

  // Auth Getters
  static String get createAccount => 'create Account'.tr;
  static String get haveAccount => 'have Account'.tr;
  static String get signIn => 'sign In'.tr;
  static String get signUp => 'sign Up'.tr;
  static String get forgotPassword => 'forgot Password'.tr;
  static String get orContinueWith => 'or Continue With'.tr;
  static String get bySigningUp => 'by Signing Up'.tr;
  static String get terms => 'terms'.tr;
  static String get privacyPolicy => 'privacyPolicy'.tr;
  static String get and => 'and'.tr;
  static String get seeHowWeUse => 'seeHowWeUse'.tr;
  static String get email => 'email'.tr;
  static String get password => 'password'.tr;
  static String get confirmPassword => 'confirm Password'.tr;
  static String get fullName => 'full Name'.tr;
  static String get phoneNumber => 'phone Number'.tr;
  static String get phoneNumberTitle => 'phone Number Title'.tr;
  static String get please => 'please'.tr;
  static String get enterPhoneNumber => 'enter Phone Number'.tr;
  static String get continueText => 'continueText'.tr;
  static String get verifyYourEmail => 'verify Your Email'.tr;
  static String get enterOtp => 'enter Otp'.tr;
  static String get resendCode => 'resend Code'.tr;
  static String get didntReceiveCode => 'didnt Receive Code'.tr;
  static String get phoneVerificationMessage => 'phone Verification Message'.tr;
  static String get verifyYourNumber => 'verify Your Number'.tr;
  static String get enterVerificationCode => 'enter Verification Code'.tr;
  static String get sentTo => 'sent To'.tr;
  static String get resendCodePrompt => 'resend Code Prompt'.tr;
  static String get resend => 'resend'.tr;
  static String get verify => 'verify'.tr;
  
  // Account Settings Getters
  static String get thatsGreatAlex => "That's Great, Alex".tr;
  static String get whichGenderDescribeYouTheBest => 'which Gender Describe You The Best?'.tr;
  static String get letsStartWithIntro => 'let\'s Start With Intro'.tr;
  static String get yourFirstName => 'Your First Name'.tr;
  static String get yourAge => 'Your Age'.tr;
  static String get showOnProfile => 'show On Profile'.tr;
  
  // Common Getters
  static String get appName => 'app Name'.tr;
  static String get next => 'next'.tr;
  static String get back => 'back'.tr;
  static String get save => 'save'.tr;
  static String get cancel => 'cancel'.tr;
  static String get error => 'error'.tr;
  static String get success => 'success'.tr;
  
  // Gender Selection
  static String get selectGender => 'select Gender'.tr;
  static String get male => 'male'.tr;
  static String get female => 'female'.tr;
  static String get other => 'other'.tr;
  static String get preferNotToSay => 'prefer Not ToSay'.tr;
  
  // Validation
  static String get fieldRequired => 'field Required'.tr;
  static String get invalidEmail => 'invalid Email'.tr;
  static String get passwordTooShort => 'password TooShort'.tr;
  static String get passwordsDontMatch => 'passwords Dont Match'.tr;
}
