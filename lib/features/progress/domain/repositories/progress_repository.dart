import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/progress.dart';

/// Contract for reading and persisting student progress.
abstract class ProgressRepository {
  /// Fetches progress from remote API (falls back to local cache on failure).
  Future<Either<Failure, Progress>> getProgress();

  /// Replaces the full progress state both locally and remotely.
  Future<Either<Failure, Unit>> saveProgress(Progress progress);

  /// Completes a lesson through the backend so parcours XP and unlocks apply.
  Future<Either<Failure, Unit>> completeLesson(String lessonId);
}
