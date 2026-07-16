import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/lesson.dart';
import '../repositories/content_repository.dart';

class GetLessonParams extends Equatable {
  const GetLessonParams({required this.lessonId});

  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class GetLessonUseCase implements UseCase<Lesson, GetLessonParams> {
  GetLessonUseCase(this._repository);

  final ContentRepository _repository;

  @override
  Future<Either<Failure, Lesson>> call(GetLessonParams params) =>
      _repository.getLesson(params.lessonId);
}
