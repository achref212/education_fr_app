// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_test_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfTestHistoryModel _$DelfTestHistoryModelFromJson(
        Map<String, dynamic> json) =>
    DelfTestHistoryModel(
      sessionId: json['sessionId'] as String,
      classLevel: json['classLevel'] as String,
      targetDelfLevel: json['targetDelfLevel'] as String,
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      comparisonToTarget: json['comparisonToTarget'] as String,
      achievedDelfLevel: json['achievedDelfLevel'] as String?,
      overallScore: (json['overallScore'] as num?)?.toInt(),
      finishedAt: json['finishedAt'] as String?,
    );

Map<String, dynamic> _$DelfTestHistoryModelToJson(
        DelfTestHistoryModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'classLevel': instance.classLevel,
      'targetDelfLevel': instance.targetDelfLevel,
      'achievedDelfLevel': instance.achievedDelfLevel,
      'overallScore': instance.overallScore,
      'categoryScores': instance.categoryScores,
      'comparisonToTarget': instance.comparisonToTarget,
      'finishedAt': instance.finishedAt,
    };
