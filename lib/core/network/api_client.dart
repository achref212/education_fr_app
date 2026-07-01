import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';
import '../storage/secure_token_storage.dart';

/// Configured [Dio] instance used by all remote data sources.
Dio buildApiClient(SecureTokenStorage tokenStorage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout:
          const Duration(milliseconds: ApiConstants.connectTimeoutMs),
      receiveTimeout:
          const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(tokenStorage),
    ErrorInterceptor(),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => _log(object.toString()),
    ),
  ]);

  return dio;
}

void _log(String message) {
  assert(() {
    // ignore: avoid_print
    print('[ApiClient] $message');
    return true;
  }());
}
