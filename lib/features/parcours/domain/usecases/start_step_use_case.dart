import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/parcours_repository.dart';

class StartStepParams extends Equatable {
  const StartStepParams({required this.stepId});

  final String stepId;

  @override
  List<Object?> get props => [stepId];
}

class StartStepUseCase implements UseCase<Unit, StartStepParams> {
  StartStepUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(StartStepParams params) =>
      _repository.startStep(params.stepId);
}
