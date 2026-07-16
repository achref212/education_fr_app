// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'step_complete_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StepCompleteResultModel _$StepCompleteResultModelFromJson(
        Map<String, dynamic> json) =>
    StepCompleteResultModel(
      stepId: json['stepId'] as String,
      score: (json['score'] as num).toInt(),
      xpEarned: (json['xpEarned'] as num).toInt(),
      passed: json['passed'] as bool,
      parcoursPercent: (json['parcoursPercent'] as num).toDouble(),
      nextStepId: json['nextStepId'] as String?,
    );

Map<String, dynamic> _$StepCompleteResultModelToJson(
        StepCompleteResultModel instance) =>
    <String, dynamic>{
      'stepId': instance.stepId,
      'score': instance.score,
      'xpEarned': instance.xpEarned,
      'passed': instance.passed,
      'nextStepId': instance.nextStepId,
      'parcoursPercent': instance.parcoursPercent,
    };
