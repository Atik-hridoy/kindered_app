import 'package:get/get.dart';
import 'app_localization.dart';

class TranslationService extends GetxService {
  static TranslationService get to => Get.find();

  final String defaultLanguage = 'en_US';
  final List<String> languages = ['en_US', 'bn_BD'];
  
  String get currentLanguage => Get.locale?.languageCode == 'bn' ? 'bn_BD' : 'en_US';

  void changeLanguage(String languageCode) {
    final locale = languageCode == 'bn_BD' 
        ? AppLocalization.bnLocale 
        : AppLocalization.enLocale;
    
    Get.updateLocale(locale);
    // Here you can also save the selected language to shared preferences
  }

  bool isCurrentLanguage(String languageCode) {
    return currentLanguage == languageCode;
  }

  // Helper method to get language name
  String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en_US':
        return 'English';
      case 'bn_BD':
        return 'বাংলা';
      default:
        return 'English';
    }
  }
}
