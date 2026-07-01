import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../features/auth/domain/usecases/get_current_user_use_case.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit({
    required GetCurrentUserUseCase getCurrentUser,
    required SharedPreferences prefs,
  })  : _getCurrentUser = getCurrentUser,
        _prefs = prefs,
        super(SplashInitial());

  final GetCurrentUserUseCase _getCurrentUser;
  final SharedPreferences _prefs;

  Future<void> checkAuthStatus() async {
    emit(SplashLoading());

    // Brief pause to let the splash animation play.
    await Future.delayed(const Duration(milliseconds: 1800));

    final hasSeenOnboarding = _prefs.getBool('has_seen_onboarding') ?? false;

    final result = await _getCurrentUser(const NoParams());
    result.fold(
      (_) => emit(SplashUnauthenticated(hasSeenOnboarding: hasSeenOnboarding)),
      (_) => emit(SplashAuthenticated()),
    );
  }
}
