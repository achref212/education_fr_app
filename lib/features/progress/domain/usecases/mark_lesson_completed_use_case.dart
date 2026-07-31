import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/progress_repository.dart';

/// Marks a single lesson as completed for the current student.
///
/// The backend awards XP and advances the parcours when the lesson belongs to
/// the current student's active learning path.
class MarkLessonCompletedUseCase
    implements UseCase<Unit, MarkLessonCompletedParams> {
  MarkLessonCompletedUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MarkLessonCompletedParams params) =>
      _repository.completeLesson(params.lessonId);
}

class MarkLessonCompletedParams extends Equatable {
  const MarkLessonCompletedParams({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}
