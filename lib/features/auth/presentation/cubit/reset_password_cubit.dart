import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/reset_password_use_case.dart';
import 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  ResetPasswordCubit({required ResetPasswordUseCase resetPasswordUseCase})
      : _resetPasswordUseCase = resetPasswordUseCase,
        super(const ResetPasswordState.initial());

  final ResetPasswordUseCase _resetPasswordUseCase;

  Future<void> reset({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    emit(const ResetPasswordState.loading());
    final result = await _resetPasswordUseCase(ResetPasswordParams(
      email: email,
      resetToken: resetToken,
      newPassword: newPassword,
    ));
    result.fold(
      (failure) => emit(ResetPasswordState.error(failure.message)),
      (_) => emit(const ResetPasswordState.success()),
    );
  }
}
