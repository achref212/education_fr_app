import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/register_use_case.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(const RegisterState.initial());

  final RegisterUseCase _registerUseCase;

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  }) async {
    emit(const RegisterState.loading());
    final result = await _registerUseCase(RegisterParams(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      classLevel: classLevel,
      schoolId: schoolId,
      phone: phone,
      dateOfBirth: dateOfBirth,
    ));
    result.fold(
      (failure) => emit(RegisterState.error(failure.message)),
      (data) => emit(RegisterState.success(
        email: data.email,
        registrationStateToken: data.registrationStateToken,
      )),
    );
  }
}
