import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/progress.dart';
import '../repositories/progress_repository.dart';

class GetProgressUseCase implements UseCase<Progress, NoParams> {
  GetProgressUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, Progress>> call(NoParams params) =>
      _repository.getProgress();
}
