import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/progress.dart';

part 'progress_model.g.dart';

/// DTO mapping the `ProgressOut` / `ProgressIn` schemas from the backend.
@JsonSerializable()
class ProgressModel {
  const ProgressModel({
    this.lessonsCompleted = const [],
    this.quizScores = const {},
    this.exerciseScores = const {},
  });

  final List<String> lessonsCompleted;
  final Map<String, List<int>> quizScores;
  final Map<String, List<int>> exerciseScores;

  factory ProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProgressModelToJson(this);

  Progress toDomain() => Progress(
        lessonsCompleted: List<String>.from(lessonsCompleted),
        quizScores: Map<String, List<int>>.from(
          quizScores.map((k, v) => MapEntry(k, List<int>.from(v))),
        ),
        exerciseScores: Map<String, List<int>>.from(
          exerciseScores.map((k, v) => MapEntry(k, List<int>.from(v))),
        ),
      );

  factory ProgressModel.fromDomain(Progress progress) => ProgressModel(
        lessonsCompleted: progress.lessonsCompleted,
        quizScores: progress.quizScores,
        exerciseScores: progress.exerciseScores,
      );
}
