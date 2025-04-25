import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class DevLogs {
  static final Logger _logger = Logger();

  static void logInfo(String msg) {
    if (kDebugMode) {
      _logger.i(msg);
    }
  }

  static void logSuccess(String msg) {
    if (kDebugMode) {
      _logger.i(msg);
    }
  }

  static void logWarning(String msg) {
    if (kDebugMode) {
      _logger.w(msg);
    }
  }

  static void logError(String msg) {
    if (kDebugMode) {
      _logger.e(msg);
    }
  }
}
