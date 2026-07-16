import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/quiz_question.dart';

part 'quiz_question_model.g.dart';

List<String> _optionsFromJson(List<dynamic> json) =>
    json.map((dynamic e) => e.toString()).toList();

@JsonSerializable()
class QuizQuestionModel {
  const QuizQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.category,
    required this.level,
    this.explanation,
  });

  final String id;
  final String question;
  @JsonKey(fromJson: _optionsFromJson)
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final String category;
  final String level;

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuizQuestionModelToJson(this);

  QuizQuestion toDomain() => QuizQuestion(
        id: id,
        question: question,
        options: options,
        correctIndex: correctIndex,
        explanation: explanation,
        category: category,
        level: level,
      );
}
