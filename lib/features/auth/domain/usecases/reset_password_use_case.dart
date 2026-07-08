import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResetPasswordUseCase implements UseCase<Unit, ResetPasswordParams> {
  ResetPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ResetPasswordParams params) =>
      _repository.resetPassword(
        email: params.email,
        resetToken: params.resetToken,
        newPassword: params.newPassword,
      );
}

class ResetPasswordParams extends Equatable {
  const ResetPasswordParams({
    required this.email,
    required this.resetToken,
    required this.newPassword,
  });

  final String email;
  final String resetToken;
  final String newPassword;

  @override
  List<Object?> get props => [email, resetToken, newPassword];
}
