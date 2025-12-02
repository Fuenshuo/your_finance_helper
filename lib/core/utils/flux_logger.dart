import 'package:flutter/foundation.dart';

/// Minimal logger used by the Flux screens while the real logger
/// implementation is still under design.
class FluxLogger {
  FluxLogger._();

  static void business(String tag, String message) {
    debugPrint('[$tag] $message');
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    debugPrint('[$tag] $message ${error ?? ''}');
    if (stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }

  static void dispose() {
    // Placeholder for the future buffered writer cleanup.
  }
}
