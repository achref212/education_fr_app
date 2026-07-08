// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resend_activation_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResendActivationResponseModel _$ResendActivationResponseModelFromJson(
        Map<String, dynamic> json) =>
    ResendActivationResponseModel(
      message: json['message'] as String,
      registrationStateToken: json['registration_state_token'] as String?,
    );

Map<String, dynamic> _$ResendActivationResponseModelToJson(
        ResendActivationResponseModel instance) =>
    <String, dynamic>{
      'message': instance.message,
      'registration_state_token': instance.registrationStateToken,
    };
