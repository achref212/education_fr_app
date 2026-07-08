import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyRegistrationUseCase implements UseCase<User, VerifyRegistrationParams> {
  VerifyRegistrationUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(VerifyRegistrationParams params) =>
      _repository.verifyRegistration(
        email: params.email,
        code: params.code,
        registrationStateToken: params.registrationStateToken,
      );
}

class VerifyRegistrationParams extends Equatable {
  const VerifyRegistrationParams({
    required this.email,
    required this.code,
    required this.registrationStateToken,
  });

  final String email;
  final String code;
  final String registrationStateToken;

  @override
  List<Object?> get props => [email, code, registrationStateToken];
}
