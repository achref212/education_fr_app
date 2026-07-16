import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_test_history.dart';

part 'delf_test_history_model.g.dart';

@JsonSerializable()
class DelfTestHistoryModel {
  const DelfTestHistoryModel({
    required this.sessionId,
    required this.classLevel,
    required this.targetDelfLevel,
    required this.categoryScores,
    required this.comparisonToTarget,
    this.achievedDelfLevel,
    this.overallScore,
    this.finishedAt,
  });

  final String sessionId;
  final String classLevel;
  final String targetDelfLevel;
  final String? achievedDelfLevel;
  final int? overallScore;
  final Map<String, int> categoryScores;
  final String comparisonToTarget;
  final String? finishedAt;

  factory DelfTestHistoryModel.fromJson(Map<String, dynamic> json) =>
      _$DelfTestHistoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfTestHistoryModelToJson(this);

  DelfTestHistory toDomain() => DelfTestHistory(
        sessionId: sessionId,
        classLevel: classLevel,
        targetDelfLevel: targetDelfLevel,
        achievedDelfLevel: achievedDelfLevel,
        overallScore: overallScore,
        categoryScores: categoryScores,
        comparisonToTarget: comparisonToTarget,
        finishedAt: finishedAt,
      );
}
