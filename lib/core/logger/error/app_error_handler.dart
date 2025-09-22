import 'package:flutter/foundation.dart';
import 'package:kindered_app/core/logger/app_logger.dart';

/// Centralized error handling for the application.
/// 
/// Handles:
/// - Flutter framework errors
/// - Asynchronous errors
/// - Uncaught exceptions
class AppErrorHandler {
  static void initialize() {
    _setupErrorHandlers();
    _logAppStart();
  }

  static void _setupErrorHandlers() {
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

    // Handle uncaught exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack);
      return true; // Prevent error from propagating
    };
  }

  static void _logError(dynamic error, StackTrace? stackTrace) {
    AppLogger.error(
      'Unhandled Exception: ${error.toString()}',
      error is Error ? error : null,
      stackTrace,
    );
    
    // Here you can add error reporting to services like:
    // - Firebase Crashlytics
    // - Sentry
    // - Your custom error tracking service
  }

  static void _logAppStart() {
    AppLogger.info('🚀 App initialized');
    AppLogger.debug(
      'App started in ${kDebugMode ? 'DEBUG' : 'RELEASE'} mode',
    );
  }
}
