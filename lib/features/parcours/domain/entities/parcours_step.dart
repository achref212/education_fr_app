import 'package:equatable/equatable.dart';

class ParcoursStep extends Equatable {
  const ParcoursStep({
    required this.id,
    required this.stepOrder,
    required this.stepType,
    required this.title,
    required this.xpReward,
    required this.status,
    this.quizCategory,
    this.lessonId,
    this.storyId,
    this.requiredStepId,
    this.score,
    this.attempts = 0,
  });

  final String id;
  final int stepOrder;
  final String stepType;
  final String title;
  final int xpReward;
  final String status;
  final String? quizCategory;
  final String? lessonId;
  final String? storyId;
  final String? requiredStepId;
  final int? score;
  final int attempts;

  bool get isLocked => status == 'locked';
  bool get isAvailable => status == 'available';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get canStart => isAvailable || isInProgress;

  @override
  List<Object?> get props => [
        id,
        stepOrder,
        stepType,
        title,
        xpReward,
        status,
        quizCategory,
        lessonId,
        storyId,
        requiredStepId,
        score,
        attempts,
      ];
}
