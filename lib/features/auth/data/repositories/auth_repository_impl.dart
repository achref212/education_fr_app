import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureTokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final SecureTokenStorage _tokenStorage;

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String level,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        level: level,
      );
      await _tokenStorage.saveAccessToken(response.accessToken);
      return Right(response.user.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _tokenStorage.saveAccessToken(response.accessToken);
      return Right(response.user.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    final hasToken = await _tokenStorage.hasToken();
    if (!hasToken) return const Left(AuthFailure());

    try {
      final userModel = await _remoteDataSource.getMe();
      return Right(userModel.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await _tokenStorage.clearAccessToken();
      return const Right(unit);
    } catch (_) {
      return const Left(CacheFailure('Impossible de déconnecter.'));
    }
  }

  Failure _mapDioFailure(DioException e) {
    final error = e.error;
    if (error is Failure) return error;
    return ServerFailure(e.message ?? 'Erreur inconnue.');
  }
}
