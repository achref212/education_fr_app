import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/parcours_step.dart';

part 'parcours_step_model.g.dart';

@JsonSerializable()
class ParcoursStepModel {
  const ParcoursStepModel({
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
    this.answers = const <Map<String, dynamic>>[],
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
  final List<Map<String, dynamic>> answers;

  factory ParcoursStepModel.fromJson(Map<String, dynamic> json) =>
      _$ParcoursStepModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParcoursStepModelToJson(this);

  ParcoursStep toDomain() => ParcoursStep(
        id: id,
        stepOrder: stepOrder,
        stepType: stepType,
        title: title,
        xpReward: xpReward,
        status: status,
        quizCategory: quizCategory,
        lessonId: lessonId,
        storyId: storyId,
        requiredStepId: requiredStepId,
        score: score,
        attempts: attempts,
        answers: answers
            .map(_answerToDomain)
            .whereType<ParcoursStepAnswer>()
            .toList(),
      );

  static ParcoursStepAnswer? _answerToDomain(Map<String, dynamic> json) {
    final questionId = json['questionId'];
    final selectedIndex = json['selectedIndex'];
    if (questionId == null || selectedIndex is! num) return null;
    return ParcoursStepAnswer(
      questionId: questionId.toString(),
      selectedIndex: selectedIndex.toInt(),
    );
  }
}
