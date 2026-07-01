// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgressModel _$ProgressModelFromJson(Map<String, dynamic> json) =>
    ProgressModel(
      lessonsCompleted: (json['lessonsCompleted'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      quizScores: (json['quizScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k,
                (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
          ) ??
          const {},
      exerciseScores: (json['exerciseScores'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k,
                (e as List<dynamic>).map((e) => (e as num).toInt()).toList()),
          ) ??
          const {},
    );

Map<String, dynamic> _$ProgressModelToJson(ProgressModel instance) =>
    <String, dynamic>{
      'lessonsCompleted': instance.lessonsCompleted,
      'quizScores': instance.quizScores,
      'exerciseScores': instance.exerciseScores,
    };
