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
    this.answers = const <StepAnswer>[],
  });

  final String stepId;
  final int score;
  final List<StepAnswer> answers;

  @override
  List<Object?> get props => [stepId, score, answers];
}

class StepAnswer extends Equatable {
  const StepAnswer({
    required this.questionId,
    required this.selectedIndex,
  });

  final String questionId;
  final int selectedIndex;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'questionId': questionId,
        'selectedIndex': selectedIndex,
      };

  @override
  List<Object?> get props => [questionId, selectedIndex];
}

class CompleteStepUseCase
    implements UseCase<StepCompleteResult, CompleteStepParams> {
  CompleteStepUseCase(this._repository);

  final ParcoursRepository _repository;

  @override
  Future<Either<Failure, StepCompleteResult>> call(CompleteStepParams params) =>
      _repository.completeStep(
        stepId: params.stepId,
        score: params.score,
        answers: params.answers,
      );
}
