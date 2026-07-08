import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/forgot_password_use_case.dart';
import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({required ForgotPasswordUseCase forgotPasswordUseCase})
      : _forgotPasswordUseCase = forgotPasswordUseCase,
        super(const ForgotPasswordState.initial());

  final ForgotPasswordUseCase _forgotPasswordUseCase;

  Future<void> requestReset({required String email}) async {
    emit(const ForgotPasswordState.loading());
    final result = await _forgotPasswordUseCase(ForgotPasswordParams(email: email));
    result.fold(
      (failure) => emit(ForgotPasswordState.error(failure.message)),
      (token) => emit(ForgotPasswordState.emailSent(
        email: email,
        resetStateToken: token,
      )),
    );
  }
}
