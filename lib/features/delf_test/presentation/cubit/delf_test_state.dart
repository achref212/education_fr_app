import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/delf_test_results.dart';
import '../../domain/entities/delf_test_section.dart';
import '../../domain/entities/delf_test_session.dart';

part 'delf_test_state.freezed.dart';

@freezed
class DelfTestState with _$DelfTestState {
  const factory DelfTestState.initial() = _Initial;
  const factory DelfTestState.loading() = _Loading;
  const factory DelfTestState.intro({
    required String classLevel,
    required String targetDelfLevel,
  }) = _Intro;
  const factory DelfTestState.questions({
    required DelfTestSession session,
    required DelfTestSection section,
    required int sectionIndex,
    required int totalSections,
  }) = _Questions;
  const factory DelfTestState.submitting() = _Submitting;
  const factory DelfTestState.results(DelfTestResults results) = _Results;
  const factory DelfTestState.error(String message) = _Error;
}
