import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ConfirmAccountDeletionUseCase
    implements UseCase<Unit, ConfirmAccountDeletionParams> {
  ConfirmAccountDeletionUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(ConfirmAccountDeletionParams params) =>
      _repository.confirmAccountDeletion(
        deletionStateToken: params.deletionStateToken,
        code: params.code,
      );
}

class ConfirmAccountDeletionParams extends Equatable {
  const ConfirmAccountDeletionParams({
    required this.deletionStateToken,
    required this.code,
  });

  final String deletionStateToken;
  final String code;

  @override
  List<Object?> get props => [deletionStateToken, code];
}
