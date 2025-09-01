import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Centralized logging utility for the application.
/// 
/// Usage:
/// ```dart
/// AppLogger.info('User logged in');
/// AppLogger.error('Failed to fetch data', error, stackTrace);
/// AppLogger.success('Profile updated successfully');
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 2,       // Number of method calls to be shown
      errorMethodCount: 5,  // Number of method calls if stacktrace is provided
      lineLength: 80,       // Width of the output
      colors: true,         // Colorful log messages
      printEmojis: true,    // Print an emoji for each log message
      printTime: true,      // Print timestamp
    ),
    output: ConsoleOutput(),
  );

  // Prevent instantiation
  AppLogger._();

  /// Log a debug message (only in debug mode)
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log an informational message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ $message', error: error, stackTrace: stackTrace);
  }

  /// Log a success message
  static void success(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('✅ $message', error: error, stackTrace: stackTrace);
  }

  /// Log a critical error
  static void critical(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf('🚨 $message', error: error, stackTrace: stackTrace);
  }
}
