import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/confirm_account_deletion_use_case.dart';
import '../../../auth/domain/usecases/request_account_deletion_code_use_case.dart';
import '../../../auth/domain/usecases/verify_account_deletion_password_use_case.dart';
import 'delete_account_state.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit({
    required VerifyAccountDeletionPasswordUseCase verifyPasswordUseCase,
    required RequestAccountDeletionCodeUseCase requestCodeUseCase,
    required ConfirmAccountDeletionUseCase confirmDeletionUseCase,
  })  : _verifyPasswordUseCase = verifyPasswordUseCase,
        _requestCodeUseCase = requestCodeUseCase,
        _confirmDeletionUseCase = confirmDeletionUseCase,
        super(const DeleteAccountState.initial());

  final VerifyAccountDeletionPasswordUseCase _verifyPasswordUseCase;
  final RequestAccountDeletionCodeUseCase _requestCodeUseCase;
  final ConfirmAccountDeletionUseCase _confirmDeletionUseCase;

  Future<void> verifyPassword(String password) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _verifyPasswordUseCase(
      VerifyAccountDeletionPasswordParams(password: password),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.message),
      ),
      (token) => emit(
        state.copyWith(
          step: DeleteAccountStep.confirmIntent,
          isLoading: false,
          deletionSessionToken: token,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> requestEmailCode() async {
    final sessionToken = state.deletionSessionToken;
    if (sessionToken == null) {
      emit(state.copyWith(
        step: DeleteAccountStep.password,
        errorMessage: 'Session de suppression expirée. Réessayez.',
      ));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _requestCodeUseCase(
      RequestAccountDeletionCodeParams(deletionSessionToken: sessionToken),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.message),
      ),
      (token) => emit(
        state.copyWith(
          step: DeleteAccountStep.code,
          isLoading: false,
          deletionStateToken: token,
          clearError: true,
        ),
      ),
    );
  }

  Future<void> confirmDeletion(String code) async {
    final stateToken = state.deletionStateToken;
    if (stateToken == null) {
      emit(state.copyWith(
        step: DeleteAccountStep.password,
        errorMessage: 'Code expiré. Relancez la suppression.',
      ));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _confirmDeletionUseCase(
      ConfirmAccountDeletionParams(
        deletionStateToken: stateToken,
        code: code,
      ),
    );
    result.fold(
      (failure) => emit(
        state.copyWith(isLoading: false, errorMessage: failure.message),
      ),
      (_) => emit(
        state.copyWith(
          step: DeleteAccountStep.success,
          isLoading: false,
          clearError: true,
        ),
      ),
    );
  }

  void returnToPasswordStep() {
    emit(const DeleteAccountState.initial());
  }
}
