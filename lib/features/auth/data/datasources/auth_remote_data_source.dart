import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/token_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String level,
  });

  Future<TokenResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<TokenResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String level,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'level': level,
      },
    );
    return TokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<TokenResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    return TokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<UserModel> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>(ApiConstants.me);
    return UserModel.fromJson(response.data!);
  }
}
