import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/delf_section_submit_result.dart';
import '../../domain/entities/delf_test_history.dart';
import '../../domain/entities/delf_test_results.dart';
import '../../domain/entities/delf_test_session.dart';
import '../../domain/repositories/delf_test_repository.dart';
import '../datasources/delf_test_remote_data_source.dart';

class DelfTestRepositoryImpl implements DelfTestRepository {
  DelfTestRepositoryImpl({required DelfTestRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final DelfTestRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, DelfTestSession>> startTest() async {
    try {
      final model = await _remoteDataSource.startTest();
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, DelfTestSession?>> getActiveTest() async {
    try {
      final model = await _remoteDataSource.getActiveTest();
      return Right(model?.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, List<DelfTestHistory>>> getHistory() async {
    try {
      final models = await _remoteDataSource.getHistory();
      return Right(models.map((m) => m.toDomain()).toList());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, DelfSectionSubmitResult>> submitSection({
    required String sessionId,
    required String category,
    required List<DelfTestAnswer> answers,
  }) async {
    try {
      final model = await _remoteDataSource.submitSection(
        sessionId: sessionId,
        category: category,
        answers: answers,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, DelfTestResults>> finishTest(String sessionId) async {
    try {
      final model = await _remoteDataSource.finishTest(sessionId);
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, DelfTestResults>> getResults(String sessionId) async {
    try {
      final model = await _remoteDataSource.getResults(sessionId);
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
