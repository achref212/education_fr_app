import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/quiz_question.dart';
import '../repositories/content_repository.dart';

class GetQuizQuestionsParams extends Equatable {
  const GetQuizQuestionsParams({this.level, this.category});

  final String? level;
  final String? category;

  @override
  List<Object?> get props => [level, category];
}

class GetQuizQuestionsUseCase
    implements UseCase<List<QuizQuestion>, GetQuizQuestionsParams> {
  GetQuizQuestionsUseCase(this._repository);

  final ContentRepository _repository;

  @override
  Future<Either<Failure, List<QuizQuestion>>> call(
    GetQuizQuestionsParams params,
  ) =>
      _repository.getQuizQuestions(
        level: params.level,
        category: params.category,
      );
}
