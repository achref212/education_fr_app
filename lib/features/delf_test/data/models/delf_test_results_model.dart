import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_test_results.dart';

part 'delf_test_results_model.g.dart';

@JsonSerializable()
class DelfTestResultsModel {
  const DelfTestResultsModel({
    required this.sessionId,
    required this.classLevel,
    required this.targetDelfLevel,
    required this.categoryScores,
    required this.comparisonToTarget,
    required this.status,
    this.achievedDelfLevel,
    this.overallScore,
    this.finishedAt,
    this.assignedLearningPathId,
    this.parcoursGeneratedByAi,
    this.parcoursAssignmentStatus,
  });

  final String sessionId;
  final String classLevel;
  final String targetDelfLevel;
  final String? achievedDelfLevel;
  final int? overallScore;
  final Map<String, int> categoryScores;
  final String comparisonToTarget;
  final String status;
  final String? finishedAt;
  final String? assignedLearningPathId;
  final bool? parcoursGeneratedByAi;
  final String? parcoursAssignmentStatus;

  factory DelfTestResultsModel.fromJson(Map<String, dynamic> json) =>
      _$DelfTestResultsModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfTestResultsModelToJson(this);

  DelfTestResults toDomain() => DelfTestResults(
        sessionId: sessionId,
        classLevel: classLevel,
        targetDelfLevel: targetDelfLevel,
        achievedDelfLevel: achievedDelfLevel,
        overallScore: overallScore,
        categoryScores: categoryScores,
        comparisonToTarget: comparisonToTarget,
        status: status,
        finishedAt: finishedAt,
        assignedLearningPathId: assignedLearningPathId,
        parcoursGeneratedByAi: parcoursGeneratedByAi,
        parcoursAssignmentStatus: parcoursAssignmentStatus,
      );
}
