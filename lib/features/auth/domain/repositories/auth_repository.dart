import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/register_result.dart';
import '../entities/school.dart';
import '../entities/user.dart';

/// Contract for all authentication operations.
abstract class AuthRepository {
  Future<Either<Failure, RegisterResult>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  });

  Future<Either<Failure, User>> verifyRegistration({
    required String email,
    required String code,
    required String registrationStateToken,
  });

  Future<Either<Failure, String?>> resendActivation({required String email});

  Future<Either<Failure, String?>> forgotPassword({required String email});

  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
    required String resetStateToken,
  });

  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });

  Future<Either<Failure, List<School>>> getSchools();

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
  });

  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, Unit>> logout();
}
