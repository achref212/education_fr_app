import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/user.dart';

part 'user_model.g.dart';

DateTime? _dateFromJson(String? value) {
  if (value == null || value.isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _dateToJson(DateTime? value) {
  if (value == null) return null;
  return '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}

/// Data transfer object for the `UserOut` schema from the backend.
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
    this.phone,
    this.dateOfBirth,
    this.classLevel,
    this.schoolId,
  });

  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String level;
  final DateTime createdAt;
  final String role;
  final bool isActive;
  final String? phone;
  @JsonKey(fromJson: _dateFromJson, toJson: _dateToJson)
  final DateTime? dateOfBirth;
  final String? classLevel;
  final String? schoolId;

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
        phone: phone,
        dateOfBirth: dateOfBirth,
        classLevel: classLevel,
        schoolId: schoolId,
      );
}
