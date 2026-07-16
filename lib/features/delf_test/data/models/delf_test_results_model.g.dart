// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_test_results_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfTestResultsModel _$DelfTestResultsModelFromJson(
        Map<String, dynamic> json) =>
    DelfTestResultsModel(
      sessionId: json['sessionId'] as String,
      classLevel: json['classLevel'] as String,
      targetDelfLevel: json['targetDelfLevel'] as String,
      categoryScores: Map<String, int>.from(json['categoryScores'] as Map),
      comparisonToTarget: json['comparisonToTarget'] as String,
      status: json['status'] as String,
      achievedDelfLevel: json['achievedDelfLevel'] as String?,
      overallScore: (json['overallScore'] as num?)?.toInt(),
      finishedAt: json['finishedAt'] as String?,
    );

Map<String, dynamic> _$DelfTestResultsModelToJson(
        DelfTestResultsModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'classLevel': instance.classLevel,
      'targetDelfLevel': instance.targetDelfLevel,
      'achievedDelfLevel': instance.achievedDelfLevel,
      'overallScore': instance.overallScore,
      'categoryScores': instance.categoryScores,
      'comparisonToTarget': instance.comparisonToTarget,
      'status': instance.status,
      'finishedAt': instance.finishedAt,
    };
