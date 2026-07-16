import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../content/domain/entities/lesson.dart';
import '../../../content/domain/entities/quiz_question.dart';
import '../../../content/domain/entities/story.dart';
import '../../domain/entities/parcours_step.dart';
import '../../domain/entities/step_complete_result.dart';

part 'step_player_state.freezed.dart';

@freezed
class StepPlayerState with _$StepPlayerState {
  const factory StepPlayerState.initial() = _Initial;
  const factory StepPlayerState.loading() = _Loading;
  const factory StepPlayerState.lesson({
    required ParcoursStep step,
    required Lesson lesson,
    required String classLevel,
  }) = _Lesson;
  const factory StepPlayerState.quiz({
    required ParcoursStep step,
    required List<QuizQuestion> questions,
    required String classLevel,
  }) = _Quiz;
  const factory StepPlayerState.story({
    required ParcoursStep step,
    required Story story,
    required String classLevel,
  }) = _Story;
  const factory StepPlayerState.completing() = _Completing;
  const factory StepPlayerState.completed(StepCompleteResult result) = _Completed;
  const factory StepPlayerState.error(String message) = _Error;
}
