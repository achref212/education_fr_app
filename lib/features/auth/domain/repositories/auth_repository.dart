import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user.dart';

/// Contract for all authentication operations.
abstract class AuthRepository {
  /// Registers a new student account and returns the authenticated [User].
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String level,
  });

  /// Authenticates with [email] + [password] and returns the [User].
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  /// Returns the currently authenticated [User] (from cache or API).
  /// Returns [AuthFailure] if no valid session exists.
  Future<Either<Failure, User>> getCurrentUser();

  /// Clears the stored token and cached user data.
  Future<Either<Failure, Unit>> logout();
}
