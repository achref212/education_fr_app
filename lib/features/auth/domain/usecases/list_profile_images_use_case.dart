import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/profile_image_asset.dart';
import '../repositories/auth_repository.dart';

class ListProfileImagesUseCase
    implements UseCase<List<ProfileImageAsset>, NoParams> {
  ListProfileImagesUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, List<ProfileImageAsset>>> call(NoParams params) {
    return _repository.listProfileImages();
  }
}
