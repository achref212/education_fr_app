import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

/// Data transfer object for the `UserOut` schema from the backend.
/// Maps JSON (camelCase) → domain [User] entity.
@JsonSerializable()
class UserModel {
  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.level,
    required this.createdAt,
    this.role = 'user',
    this.isActive = true,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String level;
  final DateTime createdAt;
  final String role;
  final bool isActive;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  User toDomain() => User(
        id: id,
        email: email,
        firstName: firstName,
        lastName: lastName,
        level: level,
        createdAt: createdAt,
        role: role,
        isActive: isActive,
      );
}
