import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/progress.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_data_source.dart';
import '../datasources/progress_remote_data_source.dart';
import '../models/progress_model.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required ProgressRemoteDataSource remoteDataSource,
    required ProgressLocalDataSource localDataSource,
    required SecureTokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _tokenStorage = tokenStorage;

  final ProgressRemoteDataSource _remoteDataSource;
  final ProgressLocalDataSource _localDataSource;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<Either<Failure, Progress>> getProgress() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) {
      return _getCachedOrEmpty();
    }

    try {
      final model = await _remoteDataSource.getProgress();
      await _localDataSource.cacheProgress(model);
      return Right(model.toDomain());
    } on DioException catch (e) {
      final failure = _mapDioFailure(e);
      if (failure is NetworkFailure) {
        return _getCachedOrEmpty();
      }
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProgress(Progress progress) async {
    final model = ProgressModel.fromDomain(progress);

    try {
      await _localDataSource.cacheProgress(model);
    } catch (_) {
      return const Left(CacheFailure());
    }

    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return const Right(unit);

    try {
      await _remoteDataSource.saveProgress(model);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  Future<Either<Failure, Progress>> _getCachedOrEmpty() async {
    try {
      final cached = await _localDataSource.getCachedProgress();
      return Right(cached?.toDomain() ?? const Progress());
    } catch (_) {
      return const Right(Progress());
    }
  }

  Failure _mapDioFailure(DioException e) {
    final error = e.error;
    if (error is Failure) return error;
    return ServerFailure(e.message ?? 'Erreur inconnue.');
  }
}
