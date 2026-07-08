import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_reset_code_state.freezed.dart';

@freezed
class VerifyResetCodeState with _$VerifyResetCodeState {
  const factory VerifyResetCodeState.initial() = _Initial;
  const factory VerifyResetCodeState.loading() = _Loading;
  const factory VerifyResetCodeState.success({required String resetToken}) = _Success;
  const factory VerifyResetCodeState.error(String message) = _Error;
}
