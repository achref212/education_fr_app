import 'package:equatable/equatable.dart';

import 'delf_test_section.dart';

class DelfTestSession extends Equatable {
  const DelfTestSession({
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
  final List<DelfTestSection> sections;
  final List<String> submittedCategories;

  DelfTestSection? get nextSection {
    for (final DelfTestSection section in sections) {
      if (!section.submitted) return section;
    }
    return null;
  }

  bool get isComplete => nextSection == null;

  @override
  List<Object?> get props => [
        sessionId,
        classLevel,
        targetDelfLevel,
        status,
        sections,
        submittedCategories,
      ];
}
