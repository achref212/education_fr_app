import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_section_submit_result.dart';

part 'delf_section_submit_result_model.g.dart';

@JsonSerializable()
class DelfSectionSubmitResultModel {
  const DelfSectionSubmitResultModel({
    required this.sessionId,
    required this.category,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.submittedCategories,
    required this.remainingCategories,
  });

  final String sessionId;
  final String category;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final List<String> submittedCategories;
  final List<String> remainingCategories;

  factory DelfSectionSubmitResultModel.fromJson(Map<String, dynamic> json) =>
      _$DelfSectionSubmitResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfSectionSubmitResultModelToJson(this);

  DelfSectionSubmitResult toDomain() => DelfSectionSubmitResult(
        sessionId: sessionId,
        category: category,
        score: score,
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        submittedCategories: submittedCategories,
        remainingCategories: remainingCategories,
      );
}
