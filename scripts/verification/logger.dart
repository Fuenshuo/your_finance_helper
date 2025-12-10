/// Verification Logger - Specialized logging for migration verification
///
/// Provides structured logging for verification operations with different
/// log levels and component-specific tracking.

enum VerificationLogLevel {
  debug,
  info,
  warning,
  error,
  success
}

class VerificationLogger {
  static const String _logPrefix = '[VERIFICATION]';

  static void debug(String component, String message, [dynamic data]) {
    _log(VerificationLogLevel.debug, component, message, data);
  }

  static void info(String component, String message, [dynamic data]) {
    _log(VerificationLogLevel.info, component, message, data);
  }

  static void warning(String component, String message, [dynamic data]) {
    _log(VerificationLogLevel.warning, component, message, data);
  }

  static void error(String component, String message, [dynamic error, StackTrace? stackTrace]) {
    _log(VerificationLogLevel.error, component, message, error);
    if (stackTrace != null) {
      print('$_logPrefix StackTrace: $stackTrace');
    }
  }

  static void success(String component, String message, [dynamic data]) {
    _log(VerificationLogLevel.success, component, message, data);
  }

  static void _log(VerificationLogLevel level, String component, String message, [dynamic data]) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = _levelToString(level);
    final prefix = '$_logPrefix [$timestamp] [$levelStr] [$component]';

    print('$prefix $message');

    if (data != null) {
      print('$prefix Data: $data');
    }
  }

  static String _levelToString(VerificationLogLevel level) {
    switch (level) {
      case VerificationLogLevel.debug:
        return 'DEBUG';
      case VerificationLogLevel.info:
        return 'INFO';
      case VerificationLogLevel.warning:
        return 'WARN';
      case VerificationLogLevel.error:
        return 'ERROR';
      case VerificationLogLevel.success:
        return 'SUCCESS';
    }
  }

  /// Log verification session start
  static void logSessionStart(String sessionId, String description) {
    info('Session', 'Starting verification session: $sessionId - $description');
  }

  /// Log verification session end
  static void logSessionEnd(String sessionId, int totalChecks, int passed, int failed) {
    final success = failed == 0;
    final level = success ? VerificationLogLevel.success : VerificationLogLevel.warning;
    _log(level, 'Session', 'Completed verification session: $sessionId - Total: $totalChecks, Passed: $passed, Failed: $failed');
  }

  /// Log component verification start
  static void logComponentStart(String componentName) {
    info(componentName, 'Starting verification');
  }

  /// Log component verification result
  static void logComponentResult(String componentName, bool success, [String? details]) {
    final level = success ? VerificationLogLevel.success : VerificationLogLevel.error;
    final message = success ? 'Verification passed' : 'Verification failed';
    _log(level, componentName, '$message${details != null ? ' - $details' : ''}');
  }

  /// Log evidence capture
  static void logEvidence(String componentName, String evidenceType, String filePath) {
    debug(componentName, 'Captured $evidenceType evidence: $filePath');
  }
}
