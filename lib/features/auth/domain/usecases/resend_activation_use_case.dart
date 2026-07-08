import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/auth_repository.dart';

class ResendActivationUseCase implements UseCase<String?, ResendActivationParams> {
  ResendActivationUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String?>> call(ResendActivationParams params) =>
      _repository.resendActivation(email: params.email);
}

class ResendActivationParams extends Equatable {
  const ResendActivationParams({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}
