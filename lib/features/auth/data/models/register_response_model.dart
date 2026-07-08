import 'package:json_annotation/json_annotation.dart';

part 'register_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterResponseModel {
  const RegisterResponseModel({
    required this.message,
    required this.registrationStateToken,
  });

  final String message;
  final String registrationStateToken;

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) =>
      _$RegisterResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$RegisterResponseModelToJson(this);
}
