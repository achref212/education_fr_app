import 'package:json_annotation/json_annotation.dart';

part 'forgot_password_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ForgotPasswordResponseModel {
  const ForgotPasswordResponseModel({
    required this.message,
    this.resetStateToken,
  });

  final String message;
  final String? resetStateToken;

  factory ForgotPasswordResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ForgotPasswordResponseModelToJson(this);
}
