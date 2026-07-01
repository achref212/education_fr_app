import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Core user domain entity — immutable, no JSON logic.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    required String level,
    required DateTime createdAt,
    @Default('user') String role,
    @Default(true) bool isActive,
  }) = _User;

  const User._();

  String get displayName => '$firstName $lastName';

  bool get isAdmin => role == 'admin';
}
