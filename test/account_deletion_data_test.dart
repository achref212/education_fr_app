import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/network/api_constants.dart';
import 'package:education_fr_app/core/storage/secure_token_storage.dart';
import 'package:education_fr_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:education_fr_app/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('account deletion data source calls password, code and confirm APIs',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          if (options.path == ApiConstants.accountDeletionPasswordCheck) {
            expect(options.method, 'POST');
            expect(options.data, {'password': 'secret-pass'});
            handler.resolve(Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'deletion_session_token': 'session-token'},
            ));
            return;
          }
          if (options.path == ApiConstants.accountDeletionRequestCode) {
            expect(options.method, 'POST');
            expect(options.data, {
              'deletion_session_token': 'session-token',
            });
            handler.resolve(Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {'deletion_state_token': 'state-token'},
            ));
            return;
          }
          if (options.path == ApiConstants.accountDeletionConfirm) {
            expect(options.method, 'POST');
            expect(options.data, {
              'deletion_state_token': 'state-token',
              'code': '123456',
            });
            handler.resolve(Response<void>(
              requestOptions: options,
              statusCode: 200,
            ));
            return;
          }
          handler.reject(DioException(
            requestOptions: options,
            error: 'Unexpected request ${options.method} ${options.path}',
          ));
        },
      ),
    );

    final remote = AuthRemoteDataSourceImpl(dio);

    final sessionToken = await remote.verifyAccountDeletionPassword(
      password: 'secret-pass',
    );
    final stateToken = await remote.requestAccountDeletionCode(
      deletionSessionToken: sessionToken,
    );
    await remote.confirmAccountDeletion(
      deletionStateToken: stateToken,
      code: '123456',
    );

    expect(sessionToken, 'session-token');
    expect(stateToken, 'state-token');
    expect(requests.map((r) => r.path), [
      ApiConstants.accountDeletionPasswordCheck,
      ApiConstants.accountDeletionRequestCode,
      ApiConstants.accountDeletionConfirm,
    ]);
  });

  test('repository clears access token after confirmed deletion', () async {
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, ApiConstants.accountDeletionConfirm);
          handler.resolve(Response<void>(
            requestOptions: options,
            statusCode: 200,
          ));
        },
      ),
    );
    final tokenStorage = SecureTokenStorage();
    await tokenStorage.saveAccessToken('jwt-token');
    final repository = AuthRepositoryImpl(
      remoteDataSource: AuthRemoteDataSourceImpl(dio),
      tokenStorage: tokenStorage,
    );

    final result = await repository.confirmAccountDeletion(
      deletionStateToken: 'state-token',
      code: '123456',
    );

    expect(result.isRight(), isTrue);
    expect(await tokenStorage.hasToken(), isFalse);
  });
}
