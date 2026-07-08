import 'package:freezed_annotation/freezed_annotation.dart';

part 'verify_account_state.freezed.dart';

@freezed
class VerifyAccountState with _$VerifyAccountState {
  const factory VerifyAccountState.initial() = _Initial;
  const factory VerifyAccountState.loading() = _Loading;
  const factory VerifyAccountState.resending() = _Resending;
  const factory VerifyAccountState.resendSuccess() = _ResendSuccess;
  const factory VerifyAccountState.success() = _Success;
  const factory VerifyAccountState.error(String message) = _Error;
}
