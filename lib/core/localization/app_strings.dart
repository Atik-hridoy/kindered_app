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
          'enterOtp': 'Enter the 6-digit code sent to',
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
          'passwordTooShort': 'passwordTooShort'.tr,
          'passwordsDontMatch': 'passwordsDontMatch'.tr,
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
          'selectGender': 'আপনার লিঙ্গ নির্বাচন করুন',
          
          // Validation
          'fieldRequired': 'এই ফিল্ডটি প্রয়োজন',
          'invalidEmail': 'সঠিক ইমেইল দিন',
        },
      };

  // Auth Getters
  static String get createAccount => 'createAccount'.tr;
  static String get haveAccount => 'haveAccount'.tr;
  static String get signIn => 'signIn'.tr;
  static String get signUp => 'signUp'.tr;
  static String get forgotPassword => 'forgotPassword'.tr;
  static String get orContinueWith => 'orContinueWith'.tr;
  static String get bySigningUp => 'bySigningUp'.tr;
  static String get terms => 'terms'.tr;
  static String get privacyPolicy => 'privacyPolicy'.tr;
  static String get and => 'and'.tr;
  static String get seeHowWeUse => 'seeHowWeUse'.tr;
  static String get email => 'email'.tr;
  static String get password => 'password'.tr;
  static String get confirmPassword => 'confirmPassword'.tr;
  static String get fullName => 'fullName'.tr;
  static String get phoneNumber => 'phoneNumber'.tr;
  static String get phoneNumberTitle => 'phoneNumberTitle'.tr;
  static String get please => 'please'.tr;
  static String get enterPhoneNumber => 'enterPhoneNumber'.tr;
  static String get continueText => 'continueText'.tr;
  static String get verifyYourEmail => 'verifyYourEmail'.tr;
  static String get enterOtp => 'enterOtp'.tr;
  static String get resendCode => 'resendCode'.tr;
  static String get didntReceiveCode => 'didntReceiveCode'.tr;
  static String get phoneVerificationMessage => 'phoneVerificationMessage'.tr;
  static String get verifyYourNumber => 'verifyYourNumber'.tr;
  static String get enterVerificationCode => 'enterVerificationCode'.tr;
  static String get sentTo => 'sentTo'.tr;
  static String get resendCodePrompt => 'resendCodePrompt'.tr;
  static String get resend => 'resend'.tr;
  static String get verify => 'verify'.tr;
  
  // Account Settings Getters
  static String get whatsYourGender => 'whatsYourGender'.tr;
  static String get selectYourGender => 'selectYourGender'.tr;
  static String get letsStartWithIntro => 'letsStartWithIntro'.tr;
  static String get yourFirstName => 'yourFirstName'.tr;
  static String get yourAge => 'yourAge'.tr;
  static String get showOnProfile => 'showOnProfile'.tr;
  
  // Common Getters
  static String get appName => 'appName'.tr;
  static String get next => 'next'.tr;
  static String get back => 'back'.tr;
  static String get save => 'save'.tr;
  static String get cancel => 'cancel'.tr;
  static String get error => 'error'.tr;
  static String get success => 'success'.tr;
  
  // Gender Selection
  static String get selectGender => 'selectGender'.tr;
  static String get male => 'male'.tr;
  static String get female => 'female'.tr;
  static String get other => 'other'.tr;
  static String get preferNotToSay => 'preferNotToSay'.tr;
  
  // Validation
  static String get fieldRequired => 'fieldRequired'.tr;
  static String get invalidEmail => 'invalidEmail'.tr;
  static String get passwordTooShort => 'passwordTooShort'.tr;
  static String get passwordsDontMatch => 'passwordsDontMatch'.tr;
}
