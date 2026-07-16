import 'package:equatable/equatable.dart';

class DelfTestHistory extends Equatable {
  const DelfTestHistory({
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

  @override
  List<Object?> get props => [
        sessionId,
        classLevel,
        targetDelfLevel,
        achievedDelfLevel,
        overallScore,
        categoryScores,
        comparisonToTarget,
        finishedAt,
      ];
}
