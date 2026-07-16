import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/step_complete_result.dart';
import '../repositories/parcours_repository.dart';

class CompleteStepParams extends Equatable {
  const CompleteStepParams({
    required this.stepId,
    required this.score,
  });

  final String stepId;
  final int score;

  @override
  List<Object?> get props => [stepId, score];
}

class CompleteStepUseCase implements UseCase<StepCompleteResult, CompleteStepParams> {
  CompleteStepUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, StepCompleteResult>> call(CompleteStepParams params) =>
      _repository.completeStep(stepId: params.stepId, score: params.score);
}
