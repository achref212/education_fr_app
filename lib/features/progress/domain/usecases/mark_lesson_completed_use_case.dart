import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/progress_repository.dart';

/// Marks a single lesson as completed for the current student.
///
/// Fetches current progress, adds [lessonId] if not already present,
/// then persists the updated progress.
class MarkLessonCompletedUseCase
    implements UseCase<Unit, MarkLessonCompletedParams> {
  MarkLessonCompletedUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(MarkLessonCompletedParams params) async {
    final result = await _repository.getProgress();
    return result.fold(
      Left.new,
      (progress) {
        if (progress.hasCompletedLesson(params.lessonId)) {
          return const Right(unit);
        }
        final updated = progress.copyWith(
          lessonsCompleted: [
            ...progress.lessonsCompleted,
            params.lessonId,
          ],
        );
        return _repository.saveProgress(updated);
      },
    );
  }
}

class MarkLessonCompletedParams extends Equatable {
  const MarkLessonCompletedParams({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}
