import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/resend_activation_use_case.dart';
import '../../domain/usecases/verify_registration_use_case.dart';
import 'verify_account_state.dart';

class VerifyAccountCubit extends Cubit<VerifyAccountState> {
  VerifyAccountCubit({
    required VerifyRegistrationUseCase verifyRegistrationUseCase,
    required ResendActivationUseCase resendActivationUseCase,
  })  : _verifyRegistrationUseCase = verifyRegistrationUseCase,
        _resendActivationUseCase = resendActivationUseCase,
        super(const VerifyAccountState.initial());

  final VerifyRegistrationUseCase _verifyRegistrationUseCase;
  final ResendActivationUseCase _resendActivationUseCase;

  String? _registrationStateToken;

  void setRegistrationStateToken(String token) {
    _registrationStateToken = token;
  }

  Future<void> verify({
    required String email,
    required String code,
  }) async {
    if (_registrationStateToken == null) {
      emit(const VerifyAccountState.error('Session expirée. Veuillez vous réinscrire.'));
      return;
    }
    emit(const VerifyAccountState.loading());
    final result = await _verifyRegistrationUseCase(VerifyRegistrationParams(
      email: email,
      code: code,
      registrationStateToken: _registrationStateToken!,
    ));
    result.fold(
      (failure) => emit(VerifyAccountState.error(failure.message)),
      (_) => emit(const VerifyAccountState.success()),
    );
  }

  Future<void> resend({required String email}) async {
    emit(const VerifyAccountState.resending());
    final result = await _resendActivationUseCase(ResendActivationParams(email: email));
    result.fold(
      (failure) => emit(VerifyAccountState.error(failure.message)),
      (token) {
        if (token != null) _registrationStateToken = token;
        emit(const VerifyAccountState.resendSuccess());
      },
    );
  }
}
