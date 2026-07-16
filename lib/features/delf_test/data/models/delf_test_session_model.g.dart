// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_test_session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfTestSessionModel _$DelfTestSessionModelFromJson(
        Map<String, dynamic> json) =>
    DelfTestSessionModel(
      sessionId: json['sessionId'] as String,
      classLevel: json['classLevel'] as String,
      targetDelfLevel: json['targetDelfLevel'] as String,
      status: json['status'] as String,
      sections: (json['sections'] as List<dynamic>)
          .map((e) => DelfTestSectionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      submittedCategories: (json['submittedCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DelfTestSessionModelToJson(
        DelfTestSessionModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'classLevel': instance.classLevel,
      'targetDelfLevel': instance.targetDelfLevel,
      'status': instance.status,
      'sections': instance.sections,
      'submittedCategories': instance.submittedCategories,
    };
