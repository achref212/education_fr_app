import 'package:auto_route/auto_route.dart';

import '../../features/delf_test/domain/entities/delf_test_session.dart';
import '../../features/delf_test/domain/usecases/get_active_delf_test_use_case.dart';
import '../../features/delf_test/domain/usecases/get_delf_history_use_case.dart';
import '../../injection/injection_container.dart';
import '../router/app_router.dart';
import '../usecase/usecase.dart';

enum PostAuthDestination {
  main,
  delfIntro,
  delfQuestions,
}

class PostAuthNavigator {
  PostAuthNavigator({
    required GetActiveDelfTestUseCase getActiveDelfTest,
    required GetDelfHistoryUseCase getDelfHistory,
  })  : _getActiveDelfTest = getActiveDelfTest,
        _getDelfHistory = getDelfHistory;

  final GetActiveDelfTestUseCase _getActiveDelfTest;
  final GetDelfHistoryUseCase _getDelfHistory;

  Future<PostAuthDestination> resolveDestination() async {
    final activeResult = await _getActiveDelfTest(const NoParams());
    final DelfTestSession? activeSession = activeResult.fold(
      (_) => null,
      (DelfTestSession? session) => session,
    );
    if (activeSession != null) {
      return PostAuthDestination.delfQuestions;
    }
    final historyResult = await _getDelfHistory(const NoParams());
    return historyResult.fold(
      (_) => PostAuthDestination.main,
      (List history) => history.isEmpty
          ? PostAuthDestination.delfIntro
          : PostAuthDestination.main,
    );
  }

  Future<void> navigate(StackRouter router) async {
    final destination = await resolveDestination();
    switch (destination) {
      case PostAuthDestination.main:
        await router.replaceAll([const MainRoute()]);
      case PostAuthDestination.delfIntro:
        await router.replaceAll([const DelfIntroRoute()]);
      case PostAuthDestination.delfQuestions:
        await router.replaceAll([const DelfQuestionRoute()]);
    }
  }
}

Future<void> navigateAfterAuth(StackRouter router) async {
  await sl<PostAuthNavigator>().navigate(router);
}
