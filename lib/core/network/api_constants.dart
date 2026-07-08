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

    // We noticed you're using a physical device (Xiaomi). 
    // Use your computer's local IP address instead of localhost or 10.0.2.2
    return 'http://192.168.100.21:8000';
  }

  static const int connectTimeoutMs = 15000;
  static const int receiveTimeoutMs = 15000;

  // Auth
  static const String register = '/auth/register';
  static const String verifyRegistration = '/auth/verify-registration';
  static const String resendActivation = '/auth/resend-activation';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String schools = '/auth/schools';
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String changePassword = '/auth/change-password';

  // Progress
  static const String progress = '/progress';
}
