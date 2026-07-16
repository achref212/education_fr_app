// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcours_step_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcoursStepModel _$ParcoursStepModelFromJson(Map<String, dynamic> json) =>
    ParcoursStepModel(
      id: json['id'] as String,
      stepOrder: (json['stepOrder'] as num).toInt(),
      stepType: json['stepType'] as String,
      title: json['title'] as String,
      xpReward: (json['xpReward'] as num).toInt(),
      status: json['status'] as String,
      quizCategory: json['quizCategory'] as String?,
      lessonId: json['lessonId'] as String?,
      storyId: json['storyId'] as String?,
      requiredStepId: json['requiredStepId'] as String?,
      score: (json['score'] as num?)?.toInt(),
      attempts: (json['attempts'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ParcoursStepModelToJson(ParcoursStepModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stepOrder': instance.stepOrder,
      'stepType': instance.stepType,
      'title': instance.title,
      'xpReward': instance.xpReward,
      'status': instance.status,
      'quizCategory': instance.quizCategory,
      'lessonId': instance.lessonId,
      'storyId': instance.storyId,
      'requiredStepId': instance.requiredStepId,
      'score': instance.score,
      'attempts': instance.attempts,
    };
