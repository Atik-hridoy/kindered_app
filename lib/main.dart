import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/config/app_themes.dart';
import 'package:kindered_app/core/logger/error/app_error_handler.dart';
import 'package:kindered_app/core/localization/app_localization.dart';
import 'package:kindered_app/core/localization/app_strings.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize error handling and logging
    AppErrorHandler.initialize();
    
    // Run the app
    runApp(const MyApp());
  } catch (error, stackTrace) {
    // Catch and log any errors during initialization
    debugPrint('❌ Fatal error during app initialization: $error');
    debugPrintStack(stackTrace: stackTrace);
    
    // Show error UI if possible
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app. Please restart.'),
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
  title: AppStrings.appName,
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme,
  initialRoute: AppRoutes.splash,
  //initialRoute: AppRoutes.homeSuggestionView,
  getPages: AppRoutes.routes,
  translations: AppStrings(),
  locale: AppLocalization.getDeviceLocale(),
  fallbackLocale: AppLocalization.enLocale,
  supportedLocales: AppLocalization.supportedLocales,
  defaultTransition: Transition.fadeIn,
  transitionDuration: const Duration(milliseconds: 10),
  opaqueRoute: Get.isOpaqueRouteDefault,
  popGesture: Get.isPopGestureEnable,
);
  }
} 