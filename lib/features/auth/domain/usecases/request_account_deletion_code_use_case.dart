import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class RequestAccountDeletionCodeUseCase
    implements UseCase<String, RequestAccountDeletionCodeParams> {
  RequestAccountDeletionCodeUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(
    RequestAccountDeletionCodeParams params,
  ) =>
      _repository.requestAccountDeletionCode(
        deletionSessionToken: params.deletionSessionToken,
      );
}

class RequestAccountDeletionCodeParams extends Equatable {
  const RequestAccountDeletionCodeParams({
    required this.deletionSessionToken,
  });

  final String deletionSessionToken;

  @override
  List<Object?> get props => [deletionSessionToken];
}
