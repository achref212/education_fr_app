import 'package:equatable/equatable.dart';

import 'parcours_step.dart';

class Parcours extends Equatable {
  const Parcours({
    required this.pathId,
    required this.title,
    required this.classLevel,
    required this.delfTargetLevel,
    required this.totalXp,
    required this.currentStreak,
    required this.preferredDifficulty,
    required this.completionPercent,
    required this.steps,
    this.description,
  });

  final String pathId;
  final String title;
  final String? description;
  final String classLevel;
  final String delfTargetLevel;
  final int totalXp;
  final int currentStreak;
  final String preferredDifficulty;
  final double completionPercent;
  final List<ParcoursStep> steps;

  ParcoursStep? getStepById(String stepId) {
    for (final ParcoursStep step in steps) {
      if (step.id == stepId) return step;
    }
    return null;
  }

  ParcoursStep? get nextStep {
    for (final ParcoursStep step in steps) {
      if (step.isAvailable || step.isInProgress) return step;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        pathId,
        title,
        description,
        classLevel,
        delfTargetLevel,
        totalXp,
        currentStreak,
        preferredDifficulty,
        completionPercent,
        steps,
      ];
}
