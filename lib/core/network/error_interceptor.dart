import 'package:dio/dio.dart';

import '../error/failures.dart';

/// Maps Dio / HTTP errors to typed [Failure] instances and rethrows them.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _mapError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: failure,
        type: err.type,
        response: err.response,
        message: failure.message,
      ),
    );
  }

  Failure _mapError(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure();
    }

    final statusCode = err.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      final detail = _extractDetail(err);
      return AuthFailure(detail ?? 'Accès non autorisé.');
    }

    if (statusCode == 404) {
      final detail = _extractDetail(err);
      return NotFoundFailure(detail ?? 'Ressource introuvable.');
    }

    if (statusCode == 422) {
      final detail = _extractDetail(err);
      return ValidationFailure(detail ?? 'Données invalides.');
    }

    if (statusCode != null && statusCode >= 500) {
      return const ServerFailure();
    }

    final detail = _extractDetail(err);
    return ServerFailure(detail ?? 'Une erreur inattendue est survenue.');
  }

  String? _extractDetail(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        return data['detail']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
