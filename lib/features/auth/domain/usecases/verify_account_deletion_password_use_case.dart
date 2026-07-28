import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class VerifyAccountDeletionPasswordUseCase
    implements UseCase<String, VerifyAccountDeletionPasswordParams> {
  VerifyAccountDeletionPasswordUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(
    VerifyAccountDeletionPasswordParams params,
  ) =>
      _repository.verifyAccountDeletionPassword(password: params.password);
}

class VerifyAccountDeletionPasswordParams extends Equatable {
  const VerifyAccountDeletionPasswordParams({required this.password});

  final String password;

  @override
  List<Object?> get props => [password];
}
