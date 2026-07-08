// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ForgotPasswordResponseModel _$ForgotPasswordResponseModelFromJson(
        Map<String, dynamic> json) =>
    ForgotPasswordResponseModel(
      message: json['message'] as String,
      resetStateToken: json['reset_state_token'] as String?,
    );

Map<String, dynamic> _$ForgotPasswordResponseModelToJson(
        ForgotPasswordResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'reset_state_token': instance.resetStateToken,
    };
