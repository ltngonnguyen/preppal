import 'package:flutter/foundation.dart'; // For kDebugMode
import 'dart:async'; // For StreamController

class SimpleLogger {
  static final List<String> _logMessages = [];
  static final StreamController<List<String>> _logStreamController = StreamController<List<String>>.broadcast();

  static Stream<List<String>> get logStream => _logStreamController.stream;
  static List<String> get messages => List.unmodifiable(_logMessages);

  static void log(String message, {String? tag}) {
    final logEntry = "${DateTime.now().toIso8601String().substring(11, 23)} ${tag != null ? '[$tag] ' : ''}: $message"; // Shorter timestamp
    if (kDebugMode) {
      print(logEntry); // Still print to console in debug mode
    }
    _logMessages.add(logEntry);
    if (_logMessages.length > 200) { // Keep a reasonable buffer
      _logMessages.removeAt(0);
    }
    _logStreamController.add(List.unmodifiable(_logMessages));
  }

  static void clear() {
    _logMessages.clear();
    _logStreamController.add(List.unmodifiable(_logMessages));
  }

  // Ensure controller is closed if app is disposed (though typically a singleton logger lives for app duration)
  // For robustness, one might add a dispose method if this logger were tied to a specific lifecycle.
  // However, for a static logger, this is less common.
}