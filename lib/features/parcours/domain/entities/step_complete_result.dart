import 'package:equatable/equatable.dart';

class StepCompleteResult extends Equatable {
  const StepCompleteResult({
    required this.stepId,
    required this.score,
    required this.xpEarned,
    required this.passed,
    required this.parcoursPercent,
    this.nextStepId,
  });

  final String stepId;
  final int score;
  final int xpEarned;
  final bool passed;
  final String? nextStepId;
  final double parcoursPercent;

  @override
  List<Object?> get props => [
        stepId,
        score,
        xpEarned,
        passed,
        nextStepId,
        parcoursPercent,
      ];
}
