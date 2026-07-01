import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../features/auth/domain/usecases/get_current_user_use_case.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({required GetCurrentUserUseCase getCurrentUser})
      : _getCurrentUser = getCurrentUser,
        super(SplashInitial());

  final GetCurrentUserUseCase _getCurrentUser;

  Future<void> checkAuthStatus() async {
    emit(SplashLoading());

    // Brief pause to let the splash animation play.
    await Future.delayed(const Duration(milliseconds: 1800));

    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (_) => emit(SplashUnauthenticated()),
      (_) => emit(SplashAuthenticated()),
    );
  }
}
