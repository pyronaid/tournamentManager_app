import 'package:flutter/foundation.dart';

/// Debug-only logging helpers.
///
/// These compile to a no-op in release builds ([kReleaseMode] is a
/// compile-time constant), so diagnostic data — PII, auth tokens, FCM
/// tokens, request/response bodies — never reaches device logs in
/// production. Use these instead of `print()` (which is *not* stripped
/// from release builds and is banned by the `avoid_print` lint).
void logDebug(Object? message) {
  if (kReleaseMode) return;
  debugPrint(message?.toString());
}

/// Logs an error (and optional [error]/[stackTrace]) in debug builds only.
void logError(Object? message, [Object? error, StackTrace? stackTrace]) {
  if (kReleaseMode) return;
  debugPrint(message?.toString());
  if (error != null) debugPrint('  error: $error');
  if (stackTrace != null) debugPrint(stackTrace.toString());
}
