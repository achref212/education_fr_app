import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/forgot_password_response_model.dart';
import '../models/register_response_model.dart';
import '../models/resend_activation_response_model.dart';
import '../models/reset_token_response_model.dart';
import '../models/school_model.dart';
import '../models/token_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  });

  Future<TokenResponseModel> verifyRegistration({
    required String email,
    required String code,
    required String registrationStateToken,
  });

  Future<ResendActivationResponseModel> resendActivation({
    required String email,
  });

  Future<ForgotPasswordResponseModel> forgotPassword({
    required String email,
  });

  Future<ResetTokenResponseModel> verifyResetCode({
    required String email,
    required String code,
    required String resetStateToken,
  });

  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  });

  Future<List<SchoolModel>> getSchools();

  Future<TokenResponseModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> getMe();

  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<RegisterResponseModel> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.register,
      data: {
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'level': 'debutant',
        'classLevel': classLevel,
        if (schoolId != null && schoolId.isNotEmpty) 'schoolId': schoolId,
        'phone': phone,
        'dateOfBirth': _formatDate(dateOfBirth),
      },
    );
    return RegisterResponseModel.fromJson(response.data!);
  }

  @override
  Future<TokenResponseModel> verifyRegistration({
    required String email,
    required String code,
    required String registrationStateToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.verifyRegistration,
      data: {
        'email': email,
        'code': code,
        'registration_state_token': registrationStateToken,
      },
    );
    return TokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<ResendActivationResponseModel> resendActivation({
    required String email,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.resendActivation,
      data: {'email': email},
    );
    return ResendActivationResponseModel.fromJson(response.data!);
  }

  @override
  Future<ForgotPasswordResponseModel> forgotPassword({
    required String email,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.forgotPassword,
      data: {'email': email},
    );
    return ForgotPasswordResponseModel.fromJson(response.data!);
  }

  @override
  Future<ResetTokenResponseModel> verifyResetCode({
    required String email,
    required String code,
    required String resetStateToken,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.verifyResetCode,
      data: {
        'email': email,
        'code': code,
        'reset_state_token': resetStateToken,
      },
    );
    return ResetTokenResponseModel.fromJson(response.data!);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      ApiConstants.resetPassword,
      data: {
        'email': email,
        'reset_token': resetToken,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<List<SchoolModel>> getSchools() async {
    final response = await _dio.get<List<dynamic>>(ApiConstants.schools);
    return (response.data ?? [])
        .map((e) => SchoolModel.fromJson(e as Map<String, dynamic>))
        .toList();
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

  @override
  Future<UserModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      ApiConstants.me,
      data: {
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (dateOfBirth != null) 'dateOfBirth': _formatDate(dateOfBirth),
      },
    );
    return UserModel.fromJson(response.data!);
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      ApiConstants.changePassword,
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
