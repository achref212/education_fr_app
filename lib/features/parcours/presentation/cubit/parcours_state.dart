import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/parcours.dart';

part 'parcours_state.freezed.dart';

@freezed
class ParcoursState with _$ParcoursState {
  const factory ParcoursState.initial() = _Initial;
  const factory ParcoursState.loading() = _Loading;
  const factory ParcoursState.loaded(Parcours parcours) = _Loaded;
  const factory ParcoursState.empty() = _Empty;
  const factory ParcoursState.error(String message) = _Error;
}
