import 'package:equatable/equatable.dart';

class DelfTestResults extends Equatable {
  const DelfTestResults({
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

  @override
  List<Object?> get props => [
        sessionId,
        classLevel,
        targetDelfLevel,
        achievedDelfLevel,
        overallScore,
        categoryScores,
        comparisonToTarget,
        status,
        finishedAt,
        assignedLearningPathId,
        parcoursGeneratedByAi,
        parcoursAssignmentStatus,
      ];
}
