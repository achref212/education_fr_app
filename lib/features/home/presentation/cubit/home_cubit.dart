import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../parcours/domain/usecases/get_parcours_summary_use_case.dart';
import '../../../parcours/domain/usecases/get_parcours_use_case.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({
    required GetParcoursSummaryUseCase getParcoursSummary,
    required GetParcoursUseCase getParcours,
  })  : _getParcoursSummary = getParcoursSummary,
        _getParcours = getParcours,
        super(const HomeState.initial());

  final GetParcoursSummaryUseCase _getParcoursSummary;
  final GetParcoursUseCase _getParcours;

  Future<void> loadHome() async {
    emit(const HomeState.loading());
    final summaryResult = await _getParcoursSummary(const NoParams());
    await summaryResult.fold(
      (failure) async {
        if (failure is NotFoundFailure) {
          emit(const HomeState.empty());
          return;
        }
        emit(HomeState.error(failure.message));
      },
      (summary) async {
        final parcoursResult = await _getParcours(const NoParams());
        parcoursResult.fold(
          (failure) {
            if (failure is NotFoundFailure) {
              emit(const HomeState.empty());
              return;
            }
            emit(HomeState.error(failure.message));
          },
          (parcours) => emit(HomeState.loaded(summary: summary, parcours: parcours)),
        );
      },
    );
  }
}
