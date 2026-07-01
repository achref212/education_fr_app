import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// All backend API endpoint constants.
///
/// Configure the base URL at build time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.x:8000
///
/// Android emulator:  http://10.0.2.2:8000
/// iOS simulator:     http://localhost:8000
class ApiConstants {
  ApiConstants._();

  static String get baseUrl {
    const definedUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (definedUrl.isNotEmpty) return definedUrl;

    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://10.0.2.2:8000';
    return 'http://localhost:8000';
  }

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String me = '/auth/me';

  // Progress
  static const String progress = '/progress';
}
