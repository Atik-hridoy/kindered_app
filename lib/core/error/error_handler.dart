import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app.dart' as app;
import '../utils/app_logger.dart';

class AppErrorHandler {
  static void setup() {
    // Handle Flutter framework errors
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack);
    };

    // Handle Dart asynchronous errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true; // Prevent error from propagating
    };

    // Handle Dart Zone errors
    runZonedGuarded<Future<void>>(
      () async {
        runApp(const app.MyApp());
      },
      (error, stackTrace) => _logError(error, stackTrace),
    );
  }

  static void _logError(dynamic error, StackTrace? stackTrace) {
    AppLogger.error(
      'Unhandled Exception: ${error.toString()}',
      error,
      stackTrace,
    );
    
    // Here you can also add error reporting to a service like Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }
}
