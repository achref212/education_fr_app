import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/usecases/get_current_user_use_case.dart';
import '../../domain/entities/delf_test_section.dart';
import '../../domain/entities/delf_test_session.dart';
import '../../domain/repositories/delf_test_repository.dart';
import '../../domain/usecases/finish_delf_test_use_case.dart';
import '../../domain/usecases/get_active_delf_test_use_case.dart';
import '../../domain/usecases/get_delf_results_use_case.dart';
import '../../domain/usecases/start_delf_test_use_case.dart';
import '../../domain/usecases/submit_delf_section_use_case.dart';
import 'delf_test_state.dart';

class DelfTestCubit extends Cubit<DelfTestState> {
  DelfTestCubit({
    required StartDelfTestUseCase startDelfTest,
    required GetActiveDelfTestUseCase getActiveDelfTest,
    required SubmitDelfSectionUseCase submitDelfSection,
    required FinishDelfTestUseCase finishDelfTest,
    required GetDelfResultsUseCase getDelfResults,
    required GetCurrentUserUseCase getCurrentUser,
  })  : _startDelfTest = startDelfTest,
        _getActiveDelfTest = getActiveDelfTest,
        _submitDelfSection = submitDelfSection,
        _finishDelfTest = finishDelfTest,
        _getDelfResults = getDelfResults,
        _getCurrentUser = getCurrentUser,
        super(const DelfTestState.initial());

  final StartDelfTestUseCase _startDelfTest;
  final GetActiveDelfTestUseCase _getActiveDelfTest;
  final SubmitDelfSectionUseCase _submitDelfSection;
  final FinishDelfTestUseCase _finishDelfTest;
  final GetDelfResultsUseCase _getDelfResults;
  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> loadIntro() async {
    emit(const DelfTestState.loading());
    final userResult = await _getCurrentUser(const NoParams());
    await userResult.fold(
      (failure) async => emit(DelfTestState.error(failure.message)),
      (User user) async {
        final activeResult = await _getActiveDelfTest(const NoParams());
        await activeResult.fold(
          (failure) async => emit(DelfTestState.error(failure.message)),
          (DelfTestSession? session) async {
            if (session != null) {
              _emitQuestions(session);
              return;
            }
            emit(
              DelfTestState.intro(
                classLevel: user.classLevel ?? '6ème année',
                targetDelfLevel: 'A1+',
              ),
            );
          },
        );
      },
    );
  }

  Future<void> startTest() async {
    emit(const DelfTestState.loading());
    final result = await _startDelfTest(const NoParams());
    result.fold(
      (failure) => emit(DelfTestState.error(failure.message)),
      _emitQuestions,
    );
  }

  Future<void> loadActiveSession() async {
    emit(const DelfTestState.loading());
    final result = await _getActiveDelfTest(const NoParams());
    result.fold(
      (failure) => emit(DelfTestState.error(failure.message)),
      (DelfTestSession? session) {
        if (session == null) {
          loadIntro();
          return;
        }
        _emitQuestions(session);
      },
    );
  }

  Future<void> submitSection({
    required DelfTestSession session,
    required DelfTestSection section,
    required Map<String, int> answers,
  }) async {
    emit(const DelfTestState.submitting());
    final List<DelfTestAnswer> payload = answers.entries
        .map(
          (MapEntry<String, int> entry) => DelfTestAnswer(
            questionId: entry.key,
            selectedIndex: entry.value,
          ),
        )
        .toList();
    final result = await _submitDelfSection(
      SubmitDelfSectionParams(
        sessionId: session.sessionId,
        category: section.category,
        answers: payload,
      ),
    );
    await result.fold(
      (failure) async => emit(DelfTestState.error(failure.message)),
      (submitResult) async {
        if (submitResult.remainingCategories.isEmpty) {
          final finishResult = await _finishDelfTest(
            FinishDelfTestParams(sessionId: session.sessionId),
          );
          finishResult.fold(
            (failure) => emit(DelfTestState.error(failure.message)),
            (results) => emit(DelfTestState.results(results)),
          );
          return;
        }
        final activeResult = await _getActiveDelfTest(const NoParams());
        activeResult.fold(
          (failure) => emit(DelfTestState.error(failure.message)),
          (DelfTestSession? updatedSession) {
            if (updatedSession == null) {
              emit(const DelfTestState.error('Session introuvable.'));
              return;
            }
            _emitQuestions(updatedSession);
          },
        );
      },
    );
  }

  Future<void> loadResults(String sessionId) async {
    emit(const DelfTestState.loading());
    final result = await _getDelfResults(
      GetDelfResultsParams(sessionId: sessionId),
    );
    result.fold(
      (failure) => emit(DelfTestState.error(failure.message)),
      (results) => emit(DelfTestState.results(results)),
    );
  }

  void _emitQuestions(DelfTestSession session) {
    final DelfTestSection? section = session.nextSection;
    if (section == null) {
      emit(const DelfTestState.error('Aucune section disponible.'));
      return;
    }
    final int sectionIndex = session.sections.indexWhere(
      (DelfTestSection s) => s.category == section.category,
    );
    emit(
      DelfTestState.questions(
        session: session,
        section: section,
        sectionIndex: sectionIndex + 1,
        totalSections: session.sections.length,
      ),
    );
  }
}
