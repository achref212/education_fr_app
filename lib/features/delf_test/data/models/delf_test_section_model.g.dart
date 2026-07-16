// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_test_section_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfTestSectionModel _$DelfTestSectionModelFromJson(
        Map<String, dynamic> json) =>
    DelfTestSectionModel(
      category: json['category'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((e) => DelfTestQuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      submitted: json['submitted'] as bool? ?? false,
      score: (json['score'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DelfTestSectionModelToJson(
        DelfTestSectionModel instance) =>
    <String, dynamic>{
      'category': instance.category,
      'questions': instance.questions,
      'submitted': instance.submitted,
      'score': instance.score,
    };
