import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GenerateProfileAvatarUseCase
    implements UseCase<User, GenerateProfileAvatarParams> {
  GenerateProfileAvatarUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(GenerateProfileAvatarParams params) async {
    final generateResult = await _repository.generateProfileAvatar(
      style: params.style,
      customization: params.customization,
      prompt: params.prompt,
    );
    return generateResult.fold(
      Left.new,
      (url) => _repository.updateProfile(profilePictureUrl: url),
    );
  }
}

class GenerateProfileAvatarParams extends Equatable {
  const GenerateProfileAvatarParams({
    required this.style,
    required this.customization,
    this.prompt,
  });

  final String style;
  final Map<String, dynamic> customization;
  final String? prompt;

  @override
  List<Object?> get props => [style, customization, prompt];
}
