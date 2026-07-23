import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/parcours.dart';
import '../entities/parcours_summary.dart';
import '../entities/step_complete_result.dart';
import '../usecases/complete_step_use_case.dart';

abstract class ParcoursRepository {
  Future<Either<Failure, Parcours>> getParcours();
  Future<Either<Failure, ParcoursSummary>> getParcoursSummary();
  Future<Either<Failure, Unit>> startStep(String stepId);
  Future<Either<Failure, StepCompleteResult>> completeStep({
    required String stepId,
    required int score,
    List<StepAnswer> answers,
  });
  Future<Either<Failure, Unit>> updateDifficulty(String difficulty);
}
