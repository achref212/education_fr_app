import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/verify_reset_code_use_case.dart';
import 'verify_reset_code_state.dart';

class VerifyResetCodeCubit extends Cubit<VerifyResetCodeState> {
  VerifyResetCodeCubit({required VerifyResetCodeUseCase verifyResetCodeUseCase})
      : _verifyResetCodeUseCase = verifyResetCodeUseCase,
        super(const VerifyResetCodeState.initial());

  final VerifyResetCodeUseCase _verifyResetCodeUseCase;

  Future<void> verify({
    required String email,
    required String code,
    required String resetStateToken,
  }) async {
    emit(const VerifyResetCodeState.loading());
    final result = await _verifyResetCodeUseCase(VerifyResetCodeParams(
      email: email,
      code: code,
      resetStateToken: resetStateToken,
    ));
    result.fold(
      (failure) => emit(VerifyResetCodeState.error(failure.message)),
      (resetToken) => emit(VerifyResetCodeState.success(resetToken: resetToken)),
    );
  }
}
