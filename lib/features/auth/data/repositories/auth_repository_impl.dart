import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/secure_token_storage.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/entities/school.dart';
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
  Future<Either<Failure, RegisterResult>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        classLevel: classLevel,
        schoolId: schoolId,
        phone: phone,
        dateOfBirth: dateOfBirth,
      );
      return Right(RegisterResult(
        email: email,
        registrationStateToken: response.registrationStateToken,
        message: response.message,
      ));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyRegistration({
    required String email,
    required String code,
    required String registrationStateToken,
  }) async {
    try {
      final response = await _remoteDataSource.verifyRegistration(
        email: email,
        code: code,
        registrationStateToken: registrationStateToken,
      );
      await _tokenStorage.saveAccessToken(response.accessToken);
      return Right(response.user.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> resendActivation(
      {required String email}) async {
    try {
      final response = await _remoteDataSource.resendActivation(email: email);
      return Right(response.registrationStateToken);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> forgotPassword(
      {required String email}) async {
    try {
      final response = await _remoteDataSource.forgotPassword(email: email);
      return Right(response.resetStateToken);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
    required String resetStateToken,
  }) async {
    try {
      final response = await _remoteDataSource.verifyResetCode(
        email: email,
        code: code,
        resetStateToken: resetStateToken,
      );
      return Right(response.resetToken);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, List<School>>> getSchools() async {
    try {
      final schools = await _remoteDataSource.getSchools();
      return Right(schools.map((s) => s.toDomain()).toList());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
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
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
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
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? profilePictureUrl,
  }) async {
    try {
      final userModel = await _remoteDataSource.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        dateOfBirth: dateOfBirth,
        profilePictureUrl: profilePictureUrl,
      );
      return Right(userModel.toDomain());
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    try {
      final url = await _remoteDataSource.uploadProfilePicture(
        bytes: bytes,
        filename: filename,
        contentType: contentType,
      );
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> generateProfileAvatar({
    required String style,
    required Map<String, dynamic> customization,
    String? prompt,
  }) async {
    try {
      final url = await _remoteDataSource.generateProfileAvatar(
        style: style,
        customization: customization,
        prompt: prompt,
      );
      return Right(url);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(unit);
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } catch (e) {
      return Left(ServerFailure('Erreur: $e'));
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
