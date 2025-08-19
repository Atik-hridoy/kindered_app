import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppLocalization {
  static const Locale enLocale = Locale('en', 'US');
  static const Locale bnLocale = Locale('bn', 'BD');
  
  static final List<Locale> supportedLocales = [
    enLocale,
    bnLocale,
  ];

  static void changeLanguage(Locale locale) {
    Get.updateLocale(locale);
  }

  static Locale? getDeviceLocale() {
    final locale = Get.deviceLocale;
    if (locale != null && supportedLocales.contains(locale)) {
      return locale;
    }
    return enLocale; // Default to English
  }
}
