import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/change_password_use_case.dart';
import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required ChangePasswordUseCase changePasswordUseCase})
      : _changePasswordUseCase = changePasswordUseCase,
        super(const ChangePasswordState.initial());

  final ChangePasswordUseCase _changePasswordUseCase;

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordState.loading());
    final result = await _changePasswordUseCase(ChangePasswordParams(
      oldPassword: oldPassword,
      newPassword: newPassword,
    ));
    result.fold(
      (failure) => emit(ChangePasswordState.error(failure.message)),
      (_) => emit(const ChangePasswordState.success()),
    );
  }
}
