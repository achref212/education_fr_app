import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/step_complete_result.dart';

part 'step_complete_result_model.g.dart';

@JsonSerializable()
class StepCompleteResultModel {
  const StepCompleteResultModel({
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

  factory StepCompleteResultModel.fromJson(Map<String, dynamic> json) =>
      _$StepCompleteResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$StepCompleteResultModelToJson(this);

  StepCompleteResult toDomain() => StepCompleteResult(
        stepId: stepId,
        score: score,
        xpEarned: xpEarned,
        passed: passed,
        nextStepId: nextStepId,
        parcoursPercent: parcoursPercent,
      );
}
