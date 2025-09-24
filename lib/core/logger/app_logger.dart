import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 🎨 Stylish centralized logging utility for the application.
/// 
/// Features:
/// - Colorful console output with emojis
/// - Structured logging with timestamps
/// - Different log levels with distinct styling
/// - Debug mode filtering
/// - Stack trace support
/// 
/// Usage:
/// ```dart
/// AppLogger.info('👤 User logged in');
/// AppLogger.error('❌ Failed to fetch data', error, stackTrace);
/// AppLogger.success('✅ Profile updated successfully');
/// AppLogger.warning('⚠️ API rate limit approaching');
/// AppLogger.debug('🔍 Debugging user session');
/// AppLogger.critical('🚨 Database connection lost');
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 3,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
      noBoxingByDefault: false,
    ),
    output: ConsoleOutput(),
  );

  // Prevent instantiation
  AppLogger._();

  /// 🔍 Check if the app is running in debug mode
  static bool get isDebugMode => kDebugMode;

  /// 🔍 Log a debug message (only in debug mode)
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _logger.d('🔍 $message', error: error, stackTrace: stackTrace);
    }
  }

  /// ℹ️ Log an informational message
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('ℹ️ $message', error: error, stackTrace: stackTrace);
  }

  /// ⚠️ Log a warning message
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w('⚠️ $message', error: error, stackTrace: stackTrace);
  }

  /// ❌ Log an error message
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e('❌ $message', error: error, stackTrace: stackTrace);
  }

  /// ✅ Log a success message
  static void success(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i('✅ $message', error: error, stackTrace: stackTrace);
  }

  /// 🚨 Log a critical error
  static void critical(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.wtf('🚨 $message', error: error, stackTrace: stackTrace);
  }

  /// 📊 Log API request/response
  static void api(String method, String endpoint, {dynamic data, int? statusCode}) {
    final statusIcon = statusCode != null ? (statusCode >= 200 && statusCode < 300 ? '✅' : '❌') : '📤';
    _logger.i('🌐 $statusIcon API $method $endpoint ${statusCode != null ? '($statusCode)' : ''}');
    if (data != null) {
      _logger.d('📦 Data: $data');
    }
  }

  /// 💾 Log database operations
  static void database(String operation, String table, {dynamic data}) {
    _logger.i('💾 $operation on $table');
    if (data != null) {
      _logger.d('📊 Data: $data');
    }
  }

  /// 🎯 Log user actions
  static void userAction(String action, {dynamic details}) {
    _logger.i('🎯 User $action');
    if (details != null) {
      _logger.d('📋 Details: $details');
    }
  }

  /// 🚀 Log performance metrics
  static void performance(String operation, Duration duration) {
    _logger.i('⏱️ $operation took ${duration.inMilliseconds}ms');
  }

  /// 🎨 Log UI events
  static void uiEvent(String event, {String? widget}) {
    final widgetInfo = widget != null ? ' ($widget)' : '';
    _logger.d('🎨 UI Event: $event$widgetInfo');
  }

  /// 📱 Log navigation events
  static void navigation(String from, String to) {
    _logger.i('📱 Navigation: $from → $to');
  }

  /// 🔧 Log configuration changes
  static void config(String key, dynamic value) {
    _logger.d('⚙️ Config: $key = $value');
  }

  /// 🎪 Log state changes
  static void stateChange(String state, dynamic from, dynamic to) {
    _logger.d('🔄 State: $state changed from $from to $to');
  }
}