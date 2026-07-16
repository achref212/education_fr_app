// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parcours_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParcoursModel _$ParcoursModelFromJson(Map<String, dynamic> json) =>
    ParcoursModel(
      pathId: json['pathId'] as String,
      title: json['title'] as String,
      classLevel: json['classLevel'] as String,
      delfTargetLevel: json['delfTargetLevel'] as String,
      totalXp: (json['totalXp'] as num).toInt(),
      currentStreak: (json['currentStreak'] as num).toInt(),
      preferredDifficulty: json['preferredDifficulty'] as String,
      completionPercent: (json['completionPercent'] as num).toDouble(),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => ParcoursStepModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$ParcoursModelToJson(ParcoursModel instance) =>
    <String, dynamic>{
      'pathId': instance.pathId,
      'title': instance.title,
      'description': instance.description,
      'classLevel': instance.classLevel,
      'delfTargetLevel': instance.delfTargetLevel,
      'totalXp': instance.totalXp,
      'currentStreak': instance.currentStreak,
      'preferredDifficulty': instance.preferredDifficulty,
      'completionPercent': instance.completionPercent,
      'steps': instance.steps,
    };
