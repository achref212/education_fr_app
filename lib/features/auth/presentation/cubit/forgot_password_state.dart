import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_state.freezed.dart';

@freezed
class ForgotPasswordState with _$ForgotPasswordState {
  const factory ForgotPasswordState.initial() = _Initial;
  const factory ForgotPasswordState.loading() = _Loading;
  const factory ForgotPasswordState.emailSent({
    required String email,
    required String? resetStateToken,
  }) = _EmailSent;
  const factory ForgotPasswordState.error(String message) = _Error;
}
