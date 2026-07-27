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
      selfieBytes: params.selfieBytes,
      selfieFilename: params.selfieFilename,
      selfieContentType: params.selfieContentType,
    );
    return generateResult.fold(
      Left.new,
      (url) => _repository.updateProfile(profilePictureUrl: url),
    );
  }
}

class GenerateProfileAvatarAssetUseCase
    implements UseCase<String, GenerateProfileAvatarParams> {
  GenerateProfileAvatarAssetUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, String>> call(GenerateProfileAvatarParams params) {
    return _repository.generateProfileAvatar(
      style: params.style,
      customization: params.customization,
      prompt: params.prompt,
      selfieBytes: params.selfieBytes,
      selfieFilename: params.selfieFilename,
      selfieContentType: params.selfieContentType,
    );
  }
}

class GenerateProfileAvatarParams extends Equatable {
  const GenerateProfileAvatarParams({
    required this.style,
    required this.customization,
    this.prompt,
    this.selfieBytes,
    this.selfieFilename,
    this.selfieContentType,
  });

  final String style;
  final Map<String, dynamic> customization;
  final String? prompt;
  final List<int>? selfieBytes;
  final String? selfieFilename;
  final String? selfieContentType;

  @override
  List<Object?> get props => [
        style,
        customization,
        prompt,
        selfieBytes,
        selfieFilename,
        selfieContentType,
      ];
}
