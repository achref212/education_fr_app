import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyResetCodeUseCase implements UseCase<String, VerifyResetCodeParams> {
  VerifyResetCodeUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(VerifyResetCodeParams params) =>
      _repository.verifyResetCode(
        email: params.email,
        code: params.code,
        resetStateToken: params.resetStateToken,
      );
}

class VerifyResetCodeParams extends Equatable {
  const VerifyResetCodeParams({
    required this.email,
    required this.code,
    required this.resetStateToken,
  });

  final String email;
  final String code;
  final String resetStateToken;

  @override
  List<Object?> get props => [email, code, resetStateToken];
}
