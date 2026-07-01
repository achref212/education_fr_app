import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/progress.dart';
import '../repositories/progress_repository.dart';

class SaveProgressUseCase implements UseCase<Unit, SaveProgressParams> {
  SaveProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(SaveProgressParams params) =>
      _repository.saveProgress(params.progress);
}

class SaveProgressParams extends Equatable {
  const SaveProgressParams({required this.progress});

  final Progress progress;

  @override
  List<Object?> get props => [progress];
}
