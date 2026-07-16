import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parcours_repository.dart';

class UpdateDifficultyParams extends Equatable {
  const UpdateDifficultyParams({required this.difficulty});

  final String difficulty;

  @override
  List<Object?> get props => [difficulty];
}

class UpdateDifficultyUseCase implements UseCase<Unit, UpdateDifficultyParams> {
  UpdateDifficultyUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(UpdateDifficultyParams params) =>
      _repository.updateDifficulty(params.difficulty);
}
