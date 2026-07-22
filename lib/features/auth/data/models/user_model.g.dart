// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      level: json['level'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      role: json['role'] as String? ?? 'user',
      isActive: json['isActive'] as bool? ?? true,
      phone: json['phone'] as String?,
      dateOfBirth: _dateFromJson(json['dateOfBirth'] as String?),
      classLevel: json['classLevel'] as String?,
      schoolId: json['schoolId'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'level': instance.level,
      'createdAt': instance.createdAt.toIso8601String(),
      'role': instance.role,
      'isActive': instance.isActive,
      'phone': instance.phone,
      'dateOfBirth': _dateToJson(instance.dateOfBirth),
      'classLevel': instance.classLevel,
      'schoolId': instance.schoolId,
      'profilePictureUrl': instance.profilePictureUrl,
    };
