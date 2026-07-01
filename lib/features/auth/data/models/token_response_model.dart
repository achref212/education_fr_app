import 'package:json_annotation/json_annotation.dart';

import 'user_model.dart';

part 'token_response_model.g.dart';

/// Maps the `TokenResponse` schema returned by `/auth/register` and `/auth/login`.
@JsonSerializable()
class TokenResponseModel {
  const TokenResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.user,
  });

  final String accessToken;
  final String tokenType;
  final UserModel user;

  factory TokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$TokenResponseModelToJson(this);
}
