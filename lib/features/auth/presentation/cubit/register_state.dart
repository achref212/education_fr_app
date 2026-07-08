import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState.initial() = _Initial;
  const factory RegisterState.loading() = _Loading;
  const factory RegisterState.success({
    required String email,
    required String registrationStateToken,
  }) = _Success;
  const factory RegisterState.error(String message) = _Error;
}
