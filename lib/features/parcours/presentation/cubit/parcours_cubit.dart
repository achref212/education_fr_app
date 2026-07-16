import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_parcours_use_case.dart';
import '../../domain/usecases/update_difficulty_use_case.dart';
import 'parcours_state.dart';

class ParcoursCubit extends Cubit<ParcoursState> {
  ParcoursCubit({
    required GetParcoursUseCase getParcours,
    required UpdateDifficultyUseCase updateDifficulty,
  })  : _getParcours = getParcours,
        _updateDifficulty = updateDifficulty,
        super(const ParcoursState.initial());

  final GetParcoursUseCase _getParcours;
  final UpdateDifficultyUseCase _updateDifficulty;

  Future<void> loadParcours() async {
    emit(const ParcoursState.loading());
    final result = await _getParcours(const NoParams());
    result.fold(
      (failure) {
        if (failure is NotFoundFailure) {
          emit(const ParcoursState.empty());
          return;
        }
        emit(ParcoursState.error(failure.message));
      },
      (parcours) => emit(ParcoursState.loaded(parcours)),
    );
  }

  Future<void> updateDifficulty(String difficulty) async {
    final result = await _updateDifficulty(
      UpdateDifficultyParams(difficulty: difficulty),
    );
    result.fold(
      (failure) => emit(ParcoursState.error(failure.message)),
      (_) => loadParcours(),
    );
  }
}
