// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delf_section_submit_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DelfSectionSubmitResultModel _$DelfSectionSubmitResultModelFromJson(
        Map<String, dynamic> json) =>
    DelfSectionSubmitResultModel(
      sessionId: json['sessionId'] as String,
      category: json['category'] as String,
      score: (json['score'] as num).toInt(),
      correctCount: (json['correctCount'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      submittedCategories: (json['submittedCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      remainingCategories: (json['remainingCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$DelfSectionSubmitResultModelToJson(
        DelfSectionSubmitResultModel instance) =>
    <String, dynamic>{
      'sessionId': instance.sessionId,
      'category': instance.category,
      'score': instance.score,
      'correctCount': instance.correctCount,
      'totalQuestions': instance.totalQuestions,
      'submittedCategories': instance.submittedCategories,
      'remainingCategories': instance.remainingCategories,
    };
