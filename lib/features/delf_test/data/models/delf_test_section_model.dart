import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_test_section.dart';
import 'delf_test_question_model.dart';

part 'delf_test_section_model.g.dart';

@JsonSerializable()
class DelfTestSectionModel {
  const DelfTestSectionModel({
    required this.category,
    required this.questions,
    this.submitted = false,
    this.score,
  });

  final String category;
  final List<DelfTestQuestionModel> questions;
  final bool submitted;
  final int? score;

  factory DelfTestSectionModel.fromJson(Map<String, dynamic> json) =>
      _$DelfTestSectionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfTestSectionModelToJson(this);

  DelfTestSection toDomain() => DelfTestSection(
        category: category,
        questions:
            questions.map((DelfTestQuestionModel q) => q.toDomain()).toList(),
        submitted: submitted,
        score: score,
      );
}
