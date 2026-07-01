import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<User, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(RegisterParams params) =>
      _repository.register(
        email: params.email,
        password: params.password,
        firstName: params.firstName,
        lastName: params.lastName,
        level: params.level,
      );
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.level,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String level;

  @override
  List<Object?> get props => [email, password, firstName, lastName, level];
}
