import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../content/domain/entities/lesson.dart';
import '../../../content/domain/entities/quiz_question.dart';
import '../../../content/domain/entities/story.dart';
import '../../../content/domain/usecases/get_lesson_use_case.dart';
import '../../../content/domain/usecases/get_quiz_questions_use_case.dart';
import '../../../content/domain/usecases/get_story_use_case.dart';
import '../../domain/entities/parcours_step.dart';
import '../../domain/usecases/complete_step_use_case.dart';
import '../../domain/usecases/get_parcours_use_case.dart';
import '../../domain/usecases/start_step_use_case.dart';
import 'step_player_state.dart';

class StepPlayerCubit extends Cubit<StepPlayerState> {
  StepPlayerCubit({
    required GetParcoursUseCase getParcours,
    required StartStepUseCase startStep,
    required CompleteStepUseCase completeStep,
    required GetLessonUseCase getLesson,
    required GetQuizQuestionsUseCase getQuizQuestions,
    required GetStoryUseCase getStory,
  })  : _getParcours = getParcours,
        _startStep = startStep,
        _completeStep = completeStep,
        _getLesson = getLesson,
        _getQuizQuestions = getQuizQuestions,
        _getStory = getStory,
        super(const StepPlayerState.initial());

  final GetParcoursUseCase _getParcours;
  final StartStepUseCase _startStep;
  final CompleteStepUseCase _completeStep;
  final GetLessonUseCase _getLesson;
  final GetQuizQuestionsUseCase _getQuizQuestions;
  final GetStoryUseCase _getStory;

  Future<void> loadStep(String stepId) async {
    emit(const StepPlayerState.loading());
    final parcoursResult = await _getParcours(const NoParams());
    await parcoursResult.fold(
      (failure) async => emit(StepPlayerState.error(failure.message)),
      (parcours) async {
        final ParcoursStep? step = parcours.getStepById(stepId);
        if (step == null) {
          emit(const StepPlayerState.error('Étape introuvable.'));
          return;
        }
        if (!step.canStart && !step.isCompleted) {
          emit(const StepPlayerState.error('Cette étape est verrouillée.'));
          return;
        }
        if (!step.isCompleted) {
          final startResult = await _startStep(StartStepParams(stepId: stepId));
          final hasStartError = startResult.fold(
            (failure) {
              emit(StepPlayerState.error(failure.message));
              return true;
            },
            (_) => false,
          );
          if (hasStartError) return;
        }
        await _loadStepContent(step, parcours.classLevel);
      },
    );
  }

  Future<void> _loadStepContent(ParcoursStep step, String classLevel) async {
    switch (step.stepType) {
      case 'lesson':
        if (step.lessonId == null) {
          emit(const StepPlayerState.error('Leçon introuvable.'));
          return;
        }
        final lessonResult =
            await _getLesson(GetLessonParams(lessonId: step.lessonId!));
        lessonResult.fold(
          (failure) => emit(StepPlayerState.error(failure.message)),
          (Lesson lesson) => emit(
            StepPlayerState.lesson(
              step: step,
              lesson: lesson,
              classLevel: classLevel,
            ),
          ),
        );
      case 'quiz':
        final quizResult = await _getQuizQuestions(
          GetQuizQuestionsParams(
            level: classLevel,
            category: step.quizCategory,
          ),
        );
        quizResult.fold(
          (failure) => emit(StepPlayerState.error(failure.message)),
          (List<QuizQuestion> questions) {
            if (questions.isEmpty) {
              emit(const StepPlayerState.error('Aucune question disponible.'));
              return;
            }
            emit(
              StepPlayerState.quiz(
                step: step,
                questions: questions,
                classLevel: classLevel,
              ),
            );
          },
        );
      case 'story':
        if (step.storyId == null) {
          emit(const StepPlayerState.error('Histoire introuvable.'));
          return;
        }
        final storyResult =
            await _getStory(GetStoryParams(storyId: step.storyId!));
        storyResult.fold(
          (failure) => emit(StepPlayerState.error(failure.message)),
          (Story story) => emit(
            StepPlayerState.story(
              step: step,
              story: story,
              classLevel: classLevel,
            ),
          ),
        );
      default:
        emit(const StepPlayerState.error('Type d\'étape non supporté.'));
    }
  }

  Future<void> completeStep({
    required String stepId,
    required int score,
    List<StepAnswer> answers = const <StepAnswer>[],
  }) async {
    emit(const StepPlayerState.completing());
    final result = await _completeStep(
      CompleteStepParams(stepId: stepId, score: score, answers: answers),
    );
    result.fold(
      (failure) => emit(StepPlayerState.error(failure.message)),
      (completeResult) => emit(StepPlayerState.completed(completeResult)),
    );
  }
}
