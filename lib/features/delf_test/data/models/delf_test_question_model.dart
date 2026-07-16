import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_test_question.dart';

part 'delf_test_question_model.g.dart';

List<String> _optionsFromJson(List<dynamic> json) =>
    json.map((dynamic e) => e.toString()).toList();

@JsonSerializable()
class DelfTestQuestionModel {
  const DelfTestQuestionModel({
    required this.id,
    required this.question,
    required this.options,
    required this.category,
    required this.level,
  });

  final String id;
  final String question;
  @JsonKey(fromJson: _optionsFromJson)
  final List<String> options;
  final String category;
  final String level;

  factory DelfTestQuestionModel.fromJson(Map<String, dynamic> json) =>
      _$DelfTestQuestionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfTestQuestionModelToJson(this);

  DelfTestQuestion toDomain() => DelfTestQuestion(
        id: id,
        question: question,
        options: options,
        category: category,
        level: level,
      );
}
