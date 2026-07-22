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
    String? phone,
    DateTime? dateOfBirth,
    String? classLevel,
    String? schoolId,
    String? profilePictureUrl,
  }) = _User;

  const User._();

  String get displayName => '$firstName $lastName';

  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  bool get isAdmin => role == 'admin';
}
