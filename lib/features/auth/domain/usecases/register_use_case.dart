import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/register_result.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<RegisterResult, RegisterParams> {
  RegisterUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, RegisterResult>> call(RegisterParams params) =>
      _repository.register(
        email: params.email,
        password: params.password,
        firstName: params.firstName,
        lastName: params.lastName,
        classLevel: params.classLevel,
        schoolId: params.schoolId,
        phone: params.phone,
        dateOfBirth: params.dateOfBirth,
      );
}

class RegisterParams extends Equatable {
  const RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.classLevel,
    this.schoolId,
    required this.phone,
    required this.dateOfBirth,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String classLevel;
  final String? schoolId;
  final String phone;
  final DateTime dateOfBirth;

  @override
  List<Object?> get props => [
        email,
        password,
        firstName,
        lastName,
        classLevel,
        schoolId,
        phone,
        dateOfBirth,
      ];
}
