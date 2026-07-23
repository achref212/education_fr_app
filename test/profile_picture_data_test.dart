import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/network/api_constants.dart';
import 'package:education_fr_app/core/storage/secure_token_storage.dart';
import 'package:education_fr_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_fr_app/features/auth/data/repositories/auth_repository_impl.dart';
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
}
