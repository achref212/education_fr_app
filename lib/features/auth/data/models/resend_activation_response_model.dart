import 'package:json_annotation/json_annotation.dart';

part 'resend_activation_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ResendActivationResponseModel {
  const ResendActivationResponseModel({
    required this.message,
    this.registrationStateToken,
  });

  final String message;
  final String? registrationStateToken;

  factory ResendActivationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResendActivationResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResendActivationResponseModelToJson(this);
}
