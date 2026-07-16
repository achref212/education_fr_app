import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/delf_test_session.dart';
import 'delf_test_section_model.dart';

part 'delf_test_session_model.g.dart';

@JsonSerializable()
class DelfTestSessionModel {
  const DelfTestSessionModel({
    required this.sessionId,
    required this.classLevel,
    required this.targetDelfLevel,
    required this.status,
    required this.sections,
    required this.submittedCategories,
  });

  final String sessionId;
  final String classLevel;
  final String targetDelfLevel;
  final String status;
  final List<DelfTestSectionModel> sections;
  final List<String> submittedCategories;

  factory DelfTestSessionModel.fromJson(Map<String, dynamic> json) =>
      _$DelfTestSessionModelFromJson(json);

  Map<String, dynamic> toJson() => _$DelfTestSessionModelToJson(this);

  DelfTestSession toDomain() => DelfTestSession(
        sessionId: sessionId,
        classLevel: classLevel,
        targetDelfLevel: targetDelfLevel,
        status: status,
        sections:
            sections.map((DelfTestSectionModel s) => s.toDomain()).toList(),
        submittedCategories: submittedCategories,
      );
}
