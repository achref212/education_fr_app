// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_test_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfTestQuestionModel _$DelfTestQuestionModelFromJson(
        Map<String, dynamic> json) =>
    DelfTestQuestionModel(
      id: json['id'] as String,
      question: json['question'] as String,
      options: _optionsFromJson(json['options'] as List),
      category: json['category'] as String,
      level: json['level'] as String,
    );

Map<String, dynamic> _$DelfTestQuestionModelToJson(
        DelfTestQuestionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'category': instance.category,
      'level': instance.level,
    };
