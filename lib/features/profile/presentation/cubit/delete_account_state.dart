import 'package:equatable/equatable.dart';

enum DeleteAccountStep { password, confirmIntent, code, success }

class DeleteAccountState extends Equatable {
  const DeleteAccountState({
    required this.step,
    this.isLoading = false,
    this.errorMessage,
    this.deletionSessionToken,
    this.deletionStateToken,
  });

  const DeleteAccountState.initial() : this(step: DeleteAccountStep.password);

  final DeleteAccountStep step;
  final bool isLoading;
  final String? errorMessage;
  final String? deletionSessionToken;
  final String? deletionStateToken;

  DeleteAccountState copyWith({
    DeleteAccountStep? step,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    String? deletionSessionToken,
    String? deletionStateToken,
  }) {
    return DeleteAccountState(
      step: step ?? this.step,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      deletionSessionToken:
          deletionSessionToken ?? this.deletionSessionToken,
      deletionStateToken: deletionStateToken ?? this.deletionStateToken,
    );
  }

  @override
  List<Object?> get props => [
        step,
        isLoading,
        errorMessage,
        deletionSessionToken,
        deletionStateToken,
      ];
}
