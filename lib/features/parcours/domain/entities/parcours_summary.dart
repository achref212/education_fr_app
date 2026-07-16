import 'package:equatable/equatable.dart';

class ParcoursSummary extends Equatable {
  const ParcoursSummary({
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

  @override
  List<Object?> get props => [
        classLevel,
        delfTargetLevel,
        completionPercent,
        totalSteps,
        completedSteps,
        totalXp,
        currentStreak,
        preferredDifficulty,
        nextStepId,
        nextStepTitle,
      ];
}
