import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kindered_app/config/app_routes.dart';
import 'package:kindered_app/config/app_themes.dart';
import 'package:kindered_app/core/logger/error/app_error_handler.dart';
import 'package:kindered_app/core/localization/app_localization.dart';
import 'package:kindered_app/core/localization/app_strings.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'modules/acccounts_setting/controller/accounts_controller.dart';
import 'local/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    AppErrorHandler.initialize();
    
    await _initializePlugins();
    
    await LocalStorage.getAllPrefData();
    
    runApp(const MyApp());
  } catch (error) {
  
    
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

Future<void> _initializePlugins() async {
  bool imagePickerOk = false;
  
  try {
    ImagePicker();
    imagePickerOk = true;
  
  } catch (e) {
  }
  
  try {
    await Permission.photos.status;
  } catch (e) {
  }
  
  if (imagePickerOk) {
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
  initialBinding: BindingsBuilder(() {
    if (!Get.isRegistered<AccountsController>()) {
      final c = Get.put(AccountsController(), permanent: true);
      if (LocalStorage.token.isNotEmpty) {
        c.initializeAccountSetupService(LocalStorage.token);
      }
    }
  }),
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