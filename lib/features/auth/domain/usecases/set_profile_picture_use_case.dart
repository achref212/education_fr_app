import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SetProfilePictureUseCase
    implements UseCase<User, SetProfilePictureParams> {
  SetProfilePictureUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(SetProfilePictureParams params) async {
    final uploadResult = await _repository.uploadProfilePicture(
      bytes: params.bytes,
      filename: params.filename,
      contentType: params.contentType,
    );
    return uploadResult.fold(
      Left.new,
      (url) => _repository.updateProfile(profilePictureUrl: url),
    );
  }
}

class SetProfilePictureParams extends Equatable {
  const SetProfilePictureParams({
    required this.bytes,
    required this.filename,
    required this.contentType,
  });

  final List<int> bytes;
  final String filename;
  final String contentType;

  @override
  List<Object?> get props => [bytes, filename, contentType];
}
