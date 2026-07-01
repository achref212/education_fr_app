import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/progress_repository.dart';

/// Appends a quiz score for a given [category] and persists progress.
class AddQuizScoreUseCase implements UseCase<Unit, AddQuizScoreParams> {
  AddQuizScoreUseCase(this._repository);

  final ProgressRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(AddQuizScoreParams params) async {
    final result = await _repository.getProgress();
    return result.fold(
      Left.new,
      (progress) {
        final currentScores = Map<String, List<int>>.from(
          progress.quizScores.map(
            (k, v) => MapEntry(k, List<int>.from(v)),
          ),
        );
        final categoryScores =
            List<int>.from(currentScores[params.category] ?? [])
              ..add(params.score);
        currentScores[params.category] = categoryScores;
        final updated = progress.copyWith(quizScores: currentScores);
        return _repository.saveProgress(updated);
      },
    );
  }
}

class AddQuizScoreParams extends Equatable {
  const AddQuizScoreParams({required this.category, required this.score});

  final String category;
  final int score;

  @override
  List<Object?> get props => [category, score];
}
