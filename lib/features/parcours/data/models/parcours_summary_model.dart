import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/parcours_summary.dart';

part 'parcours_summary_model.g.dart';

@JsonSerializable()
class ParcoursSummaryModel {
  const ParcoursSummaryModel({
    required this.classLevel,
    required this.delfTargetLevel,
    required this.completionPercent,
    required this.totalSteps,
    required this.completedSteps,
    required this.totalXp,
    required this.currentStreak,
    required this.preferredDifficulty,
    this.nextStepId,
    this.nextStepTitle,
  });

  final String classLevel;
  final String delfTargetLevel;
  final double completionPercent;
  final int totalSteps;
  final int completedSteps;
  final int totalXp;
  final int currentStreak;
  final String preferredDifficulty;
  final String? nextStepId;
  final String? nextStepTitle;

  factory ParcoursSummaryModel.fromJson(Map<String, dynamic> json) =>
      _$ParcoursSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParcoursSummaryModelToJson(this);

  ParcoursSummary toDomain() => ParcoursSummary(
        classLevel: classLevel,
        delfTargetLevel: delfTargetLevel,
        completionPercent: completionPercent,
        totalSteps: totalSteps,
        completedSteps: completedSteps,
        totalXp: totalXp,
        currentStreak: currentStreak,
        preferredDifficulty: preferredDifficulty,
        nextStepId: nextStepId,
        nextStepTitle: nextStepTitle,
      );
}
