// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcours_summary_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcoursSummaryModel _$ParcoursSummaryModelFromJson(
        Map<String, dynamic> json) =>
    ParcoursSummaryModel(
      classLevel: json['classLevel'] as String,
      delfTargetLevel: json['delfTargetLevel'] as String,
      completionPercent: (json['completionPercent'] as num).toDouble(),
      totalSteps: (json['totalSteps'] as num).toInt(),
      completedSteps: (json['completedSteps'] as num).toInt(),
      totalXp: (json['totalXp'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      preferredDifficulty: json['preferredDifficulty'] as String,
      nextStepId: json['nextStepId'] as String?,
      nextStepTitle: json['nextStepTitle'] as String?,
    );

Map<String, dynamic> _$ParcoursSummaryModelToJson(
        ParcoursSummaryModel instance) =>
    <String, dynamic>{
      'classLevel': instance.classLevel,
      'delfTargetLevel': instance.delfTargetLevel,
      'completionPercent': instance.completionPercent,
      'totalSteps': instance.totalSteps,
      'completedSteps': instance.completedSteps,
      'totalXp': instance.totalXp,
      'currentStreak': instance.currentStreak,
      'preferredDifficulty': instance.preferredDifficulty,
      'nextStepId': instance.nextStepId,
      'nextStepTitle': instance.nextStepTitle,
    };
