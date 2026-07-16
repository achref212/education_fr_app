import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/story.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/content_remote_data_source.dart';

class ContentRepositoryImpl implements ContentRepository {
  ContentRepositoryImpl({required ContentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ContentRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Lesson>> getLesson(String lessonId) async {
    try {
      final model = await _remoteDataSource.getLesson(lessonId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions({
    String? level,
    String? category,
  }) async {
    try {
      final models = await _remoteDataSource.getQuizQuestions(
        level: level,
        category: category,
      );
      return Right(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, Story>> getStory(String storyId) async {
    try {
      final model = await _remoteDataSource.getStory(storyId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  Failure _mapDioFailure(DioException e) {
    final error = e.error;
    if (error is Failure) return error;
    return ServerFailure(e.message ?? 'Erreur inconnue.');
  }
}
