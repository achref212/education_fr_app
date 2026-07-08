import 'package:json_annotation/json_annotation.dart';

part 'reset_token_response_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ResetTokenResponseModel {
  const ResetTokenResponseModel({required this.resetToken});

  final String resetToken;

  factory ResetTokenResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ResetTokenResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ResetTokenResponseModelToJson(this);
}
