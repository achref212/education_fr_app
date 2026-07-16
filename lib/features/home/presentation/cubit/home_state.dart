import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../parcours/domain/entities/parcours.dart';
import '../../../parcours/domain/entities/parcours_summary.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial() = _Initial;
  const factory HomeState.loading() = _Loading;
  const factory HomeState.loaded({
    required ParcoursSummary summary,
    required Parcours parcours,
  }) = _Loaded;
  const factory HomeState.empty() = _Empty;
  const factory HomeState.error(String message) = _Error;
}
