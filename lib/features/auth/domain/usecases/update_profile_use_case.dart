import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfileUseCase implements UseCase<User, UpdateProfileParams> {
  UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(UpdateProfileParams params) =>
      _repository.updateProfile(
        firstName: params.firstName,
        lastName: params.lastName,
        phone: params.phone,
        dateOfBirth: params.dateOfBirth,
        profilePictureUrl: params.profilePictureUrl,
      );
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({
    this.firstName,
    this.lastName,
    this.phone,
    this.dateOfBirth,
    this.profilePictureUrl,
  });

  final String? firstName;
  final String? lastName;
  final String? phone;
  final DateTime? dateOfBirth;
  final String? profilePictureUrl;

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        phone,
        dateOfBirth,
        profilePictureUrl,
      ];
}
