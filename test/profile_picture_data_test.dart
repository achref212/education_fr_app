import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/network/api_constants.dart';
import 'package:education_fr_app/core/storage/secure_token_storage.dart';
import 'package:education_fr_app/core/usecase/usecase.dart';
import 'package:education_fr_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_fr_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:education_fr_app/features/auth/domain/usecases/generate_profile_avatar_use_case.dart';
import 'package:education_fr_app/features/auth/domain/usecases/list_profile_images_use_case.dart';
import 'package:education_fr_app/features/auth/domain/usecases/set_profile_picture_use_case.dart';

void main() {
  test('set profile picture uploads multipart then patches profile URL',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.path == ApiConstants.profileUpload) {
            expect(options.data, isA<FormData>());
            final form = options.data as FormData;
            expect(form.files.single.key, 'file');
            expect(form.files.single.value.filename, 'avatar.png');
            expect(
              form.files.single.value.contentType.toString(),
              'image/png',
            );
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {'url': '/media/images/avatar.png'},
              ),
            );
            return;
          }
          if (options.path == ApiConstants.me && options.method == 'PATCH') {
            expect(
                options.data['profilePictureUrl'], '/media/images/avatar.png');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'student-1',
                  'email': 'student@example.com',
                  'firstName': 'Sana',
                  'lastName': 'Student',
                  'level': 'A1',
                  'createdAt': '2026-01-01T00:00:00Z',
                  'role': 'user',
                  'isActive': true,
                  'profilePictureUrl': '/media/images/avatar.png',
                },
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected request ${options.method} ${options.path}',
            ),
          );
        },
      ),
    );

    final remote = AuthRemoteDataSourceImpl(dio);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: SecureTokenStorage(),
    );
    final useCase = SetProfilePictureUseCase(repository);

    final result = await useCase(
      const SetProfilePictureParams(
        bytes: [0x89, 0x50, 0x4E, 0x47],
        filename: 'avatar.png',
        contentType: 'image/png',
      ),
    );

    expect(result.isRight(), isTrue);
    final user = result.getOrElse(() => throw StateError('expected user'));
    expect(user.profilePictureUrl, '/media/images/avatar.png');
    expect(requests, hasLength(2));
    expect(requests[0].method, 'POST');
    expect(requests[0].path, ApiConstants.profileUpload);
    expect(requests[1].method, 'PATCH');
    expect(requests[1].path, ApiConstants.me);
  });

  test('generate profile avatar with selfie uploads multipart then patches URL',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.path == ApiConstants.profileAvatarGenerateFromSelfie) {
            expect(options.data, isA<FormData>());
            final form = options.data as FormData;
            expect(form.fields.firstWhere((f) => f.key == 'style').value,
                'realistic');
            expect(
              jsonDecode(
                form.fields.firstWhere((f) => f.key == 'customization').value,
              ),
              containsPair('gender', 'girl'),
            );
            expect(form.files.single.key, 'selfie');
            expect(form.files.single.value.filename, 'selfie.jpg');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {'url': '/media/images/ai-avatar.png'},
              ),
            );
            return;
          }
          if (options.path == ApiConstants.me && options.method == 'PATCH') {
            expect(options.data['profilePictureUrl'],
                '/media/images/ai-avatar.png');
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'id': 'student-1',
                  'email': 'student@example.com',
                  'firstName': 'Sana',
                  'lastName': 'Student',
                  'level': 'A1',
                  'createdAt': '2026-01-01T00:00:00Z',
                  'role': 'user',
                  'isActive': true,
                  'profilePictureUrl': '/media/images/ai-avatar.png',
                },
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected request ${options.method} ${options.path}',
            ),
          );
        },
      ),
    );

    final remote = AuthRemoteDataSourceImpl(dio);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: SecureTokenStorage(),
    );
    final useCase = GenerateProfileAvatarUseCase(repository);

    final result = await useCase(
      const GenerateProfileAvatarParams(
        style: 'realistic',
        customization: {'gender': 'girl'},
        prompt: 'soft school avatar',
        selfieBytes: [0xFF, 0xD8, 0xFF],
        selfieFilename: 'selfie.jpg',
        selfieContentType: 'image/jpeg',
      ),
    );

    expect(result.isRight(), isTrue);
    final user = result.getOrElse(() => throw StateError('expected user'));
    expect(user.profilePictureUrl, '/media/images/ai-avatar.png');
    expect(requests, hasLength(2));
    expect(requests[0].method, 'POST');
    expect(requests[0].path, ApiConstants.profileAvatarGenerateFromSelfie);
    expect(requests[1].method, 'PATCH');
    expect(requests[1].path, ApiConstants.me);
  });

  test('generate profile avatar asset returns URL before profile patch',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.path == ApiConstants.profileAvatarGenerate) {
            expect(options.data['style'], 'cartoon');
            expect(
                options.data['customization'], containsPair('gender', 'boy'));
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 201,
                data: {'url': '/media/images/ai-avatar.png'},
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected request ${options.method} ${options.path}',
            ),
          );
        },
      ),
    );

    final remote = AuthRemoteDataSourceImpl(dio);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: SecureTokenStorage(),
    );
    final useCase = GenerateProfileAvatarAssetUseCase(repository);

    final result = await useCase(
      const GenerateProfileAvatarParams(
        style: 'cartoon',
        customization: {'gender': 'boy'},
      ),
    );

    expect(result.isRight(), isTrue);
    expect(result.getOrElse(() => ''), '/media/images/ai-avatar.png');
    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.path, ApiConstants.profileAvatarGenerate);
  });

  test('list profile images returns previous profile media assets', () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.path == ApiConstants.profileImages) {
            handler.resolve(
              Response<List<dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: [
                  {
                    'id': 'asset-1',
                    'url': '/media/images/profile-1.png',
                    'title': 'Photo récente',
                    'mimeType': 'image/png',
                    'createdAt': '2026-07-27T09:00:00Z',
                  },
                ],
              ),
            );
            return;
          }
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected request ${options.method} ${options.path}',
            ),
          );
        },
      ),
    );

    final remote = AuthRemoteDataSourceImpl(dio);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remote,
      tokenStorage: SecureTokenStorage(),
    );
    final useCase = ListProfileImagesUseCase(repository);

    final result = await useCase(const NoParams());

    expect(result.isRight(), isTrue);
    final assets = result.getOrElse(() => throw StateError('expected assets'));
    expect(assets, hasLength(1));
    expect(assets.single.url, '/media/images/profile-1.png');
    expect(assets.single.title, 'Photo récente');
    expect(requests, hasLength(1));
    expect(requests.single.method, 'GET');
    expect(requests.single.path, ApiConstants.profileImages);
  });
}
