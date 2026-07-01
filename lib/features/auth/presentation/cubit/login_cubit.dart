import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/login_use_case.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required LoginUseCase loginUseCase,
  })  : _loginUseCase = loginUseCase,
        super(const LoginState.initial());

  final LoginUseCase _loginUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginState.loading());
    final result = await _loginUseCase(LoginParams(email: email, password: password));
    result.fold(
      (failure) => emit(LoginState.error(failure.message)),
      (_) => emit(const LoginState.success()),
    );
  }
}