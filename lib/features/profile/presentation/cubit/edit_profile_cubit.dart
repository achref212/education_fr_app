import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/usecases/update_profile_use_case.dart';
import 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  EditProfileCubit({required UpdateProfileUseCase updateProfileUseCase})
      : _updateProfileUseCase = updateProfileUseCase,
        super(const EditProfileState.initial());

  final UpdateProfileUseCase _updateProfileUseCase;

  Future<void> save({
    required String firstName,
    required String lastName,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    emit(const EditProfileState.loading());
    final result = await _updateProfileUseCase(UpdateProfileParams(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
    ));
    result.fold(
      (failure) => emit(EditProfileState.error(failure.message)),
      (user) => emit(EditProfileState.success(user)),
    );
  }
}
