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
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize error handling and logging
    AppErrorHandler.initialize();
    
    // Initialize plugins
    await _initializePlugins();
    
    // Load persisted auth/session data so token/email are available
    await LocalStorage.getAllPrefData();
    
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

Future<void> _initializePlugins() async {
  bool imagePickerOk = false;
  
  try {
    // Test image picker plugin
    ImagePicker();
    debugPrint('✅ ImagePicker plugin initialized successfully');
    imagePickerOk = true;
  } catch (e) {
    debugPrint('❌ ImagePicker plugin initialization failed: $e');
  }
  
  try {
    // Test permission handler plugin
    await Permission.photos.status;
    debugPrint('✅ PermissionHandler plugin initialized successfully');
  } catch (e) {
    debugPrint('⚠️ PermissionHandler plugin initialization failed: $e');
    debugPrint('🔄 Will attempt to proceed without PermissionHandler');
  }
  
  if (imagePickerOk) {
    debugPrint('🔧 Core plugins initialized successfully');
  } else {
    debugPrint('❌ Critical plugin initialization failed');
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
  //initialRoute: AppRoutes.visualStoryView,
  initialBinding: BindingsBuilder(() {
    // Register a single, permanent AccountsController instance for the whole app
    if (!Get.isRegistered<AccountsController>()) {
      final c = Get.put(AccountsController(), permanent: true);
      // Initialize bearer token if available
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