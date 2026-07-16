import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/parcours.dart';
import 'parcours_step_model.dart';

part 'parcours_model.g.dart';

@JsonSerializable()
class ParcoursModel {
  const ParcoursModel({
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
  final List<ParcoursStepModel> steps;

  factory ParcoursModel.fromJson(Map<String, dynamic> json) =>
      _$ParcoursModelFromJson(json);

  Map<String, dynamic> toJson() => _$ParcoursModelToJson(this);

  Parcours toDomain() => Parcours(
        pathId: pathId,
        title: title,
        description: description,
        classLevel: classLevel,
        delfTargetLevel: delfTargetLevel,
        totalXp: totalXp,
        currentStreak: currentStreak,
        preferredDifficulty: preferredDifficulty,
        completionPercent: completionPercent,
        steps: steps.map((ParcoursStepModel s) => s.toDomain()).toList(),
      );
}
