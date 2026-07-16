// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuizQuestionModel _$QuizQuestionModelFromJson(Map<String, dynamic> json) =>
    QuizQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: _optionsFromJson(json['options'] as List),
      correctIndex: (json['correctIndex'] as num).toInt(),
      category: json['category'] as String,
      level: json['level'] as String,
      explanation: json['explanation'] as String?,
    );

Map<String, dynamic> _$QuizQuestionModelToJson(QuizQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctIndex': instance.correctIndex,
      'explanation': instance.explanation,
      'category': instance.category,
      'level': instance.level,
    };
