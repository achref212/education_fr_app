import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/parcours.dart';
import '../../domain/entities/parcours_summary.dart';
import '../../domain/entities/step_complete_result.dart';
import '../../domain/repositories/parcours_repository.dart';
import '../datasources/parcours_remote_data_source.dart';

class ParcoursRepositoryImpl implements ParcoursRepository {
  ParcoursRepositoryImpl({required ParcoursRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ParcoursRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, Parcours>> getParcours() async {
    try {
      final model = await _remoteDataSource.getParcours();
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, ParcoursSummary>> getParcoursSummary() async {
    try {
      final model = await _remoteDataSource.getParcoursSummary();
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> startStep(String stepId) async {
    try {
      await _remoteDataSource.startStep(stepId);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, StepCompleteResult>> completeStep({
    required String stepId,
    required int score,
  }) async {
    try {
      final model = await _remoteDataSource.completeStep(
        stepId: stepId,
        score: score,
      );
      return Right(model.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateDifficulty(String difficulty) async {
    try {
      await _remoteDataSource.updateDifficulty(difficulty);
      return const Right(unit);
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
