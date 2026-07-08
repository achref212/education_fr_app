import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_token_storage.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../features/auth/domain/usecases/get_schools_use_case.dart';
import '../features/auth/domain/usecases/login_use_case.dart';
import '../features/auth/domain/usecases/logout_use_case.dart';
import '../features/auth/domain/usecases/register_use_case.dart';
import '../features/auth/domain/usecases/resend_activation_use_case.dart';
import '../features/auth/domain/usecases/reset_password_use_case.dart';
import '../features/auth/domain/usecases/verify_registration_use_case.dart';
import '../features/auth/domain/usecases/verify_reset_code_use_case.dart';
import '../features/auth/domain/usecases/change_password_use_case.dart';
import '../features/auth/domain/usecases/update_profile_use_case.dart';
import '../features/auth/presentation/cubit/forgot_password_cubit.dart';
import '../features/auth/presentation/cubit/login_cubit.dart';
import '../features/auth/presentation/cubit/register_cubit.dart';
import '../features/auth/presentation/cubit/reset_password_cubit.dart';
import '../features/auth/presentation/cubit/verify_account_cubit.dart';
import '../features/auth/presentation/cubit/verify_reset_code_cubit.dart';
import '../features/progress/data/datasources/progress_local_data_source.dart';
import '../features/progress/data/datasources/progress_remote_data_source.dart';
import '../features/progress/data/repositories/progress_repository_impl.dart';
import '../features/progress/domain/repositories/progress_repository.dart';
import '../features/progress/domain/usecases/add_quiz_score_use_case.dart';
import '../features/progress/domain/usecases/get_progress_use_case.dart';
import '../features/progress/domain/usecases/mark_lesson_completed_use_case.dart';
import '../features/progress/domain/usecases/save_progress_use_case.dart';
import '../features/theme/data/datasources/theme_local_data_source.dart';
import '../features/theme/data/repositories/theme_repository_impl.dart';
import '../features/theme/domain/repositories/theme_repository.dart';
import '../features/theme/domain/usecases/get_theme_mode_use_case.dart';
import '../features/theme/domain/usecases/set_theme_mode_use_case.dart';
import '../features/theme/presentation/cubit/theme_cubit.dart';
import '../features/profile/presentation/cubit/change_password_cubit.dart';
import '../features/profile/presentation/cubit/edit_profile_cubit.dart';
import '../features/profile/presentation/cubit/profile_cubit.dart';
import '../features/splash/presentation/cubit/splash_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _registerCore();
  _registerThemeFeature();
  _registerAuthFeature();
  _registerProfileFeature();
  _registerProgressFeature();
}

Future<void> _registerCore() async {
  sl.registerLazySingleton<SecureTokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<Dio>(() => buildApiClient(sl<SecureTokenStorage>()));
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
}

void _registerThemeFeature() {
  sl.registerLazySingleton<ThemeLocalDataSource>(
    () => ThemeLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ThemeRepository>(
    () => ThemeRepositoryImpl(sl<ThemeLocalDataSource>()),
  );
  sl.registerLazySingleton<GetThemeModeUseCase>(
    () => GetThemeModeUseCase(sl<ThemeRepository>()),
  );
  sl.registerLazySingleton<SetThemeModeUseCase>(
    () => SetThemeModeUseCase(sl<ThemeRepository>()),
  );
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(
      getThemeMode: sl<GetThemeModeUseCase>(),
      setThemeMode: sl<SetThemeModeUseCase>(),
    ),
  );
}

void _registerAuthFeature() {
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      tokenStorage: sl<SecureTokenStorage>(),
    ),
  );
  sl.registerFactory<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));
  sl.registerFactory<RegisterUseCase>(
      () => RegisterUseCase(sl<AuthRepository>()));
  sl.registerFactory<VerifyRegistrationUseCase>(
      () => VerifyRegistrationUseCase(sl<AuthRepository>()));
  sl.registerFactory<ResendActivationUseCase>(
      () => ResendActivationUseCase(sl<AuthRepository>()));
  sl.registerFactory<ForgotPasswordUseCase>(
      () => ForgotPasswordUseCase(sl<AuthRepository>()));
  sl.registerFactory<VerifyResetCodeUseCase>(
      () => VerifyResetCodeUseCase(sl<AuthRepository>()));
  sl.registerFactory<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(sl<AuthRepository>()));
  sl.registerFactory<GetSchoolsUseCase>(
      () => GetSchoolsUseCase(sl<AuthRepository>()));
  sl.registerFactory<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerFactory<LogoutUseCase>(() => LogoutUseCase(sl<AuthRepository>()));

  sl.registerFactory<SplashCubit>(
    () => SplashCubit(
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      prefs: sl<SharedPreferences>(),
    ),
  );

  sl.registerFactory<LoginCubit>(
    () => LoginCubit(loginUseCase: sl<LoginUseCase>()),
  );

  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(registerUseCase: sl<RegisterUseCase>()),
  );

  sl.registerFactory<VerifyAccountCubit>(
    () => VerifyAccountCubit(
      verifyRegistrationUseCase: sl<VerifyRegistrationUseCase>(),
      resendActivationUseCase: sl<ResendActivationUseCase>(),
    ),
  );

  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(forgotPasswordUseCase: sl<ForgotPasswordUseCase>()),
  );

  sl.registerFactory<VerifyResetCodeCubit>(
    () => VerifyResetCodeCubit(
      verifyResetCodeUseCase: sl<VerifyResetCodeUseCase>(),
    ),
  );

  sl.registerFactory<ResetPasswordCubit>(
    () => ResetPasswordCubit(resetPasswordUseCase: sl<ResetPasswordUseCase>()),
  );

  sl.registerFactory<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(sl<AuthRepository>()));
  sl.registerFactory<ChangePasswordUseCase>(
      () => ChangePasswordUseCase(sl<AuthRepository>()));
}

void _registerProfileFeature() {
  sl.registerFactory<ProfileCubit>(
    () => ProfileCubit(
      getCurrentUserUseCase: sl<GetCurrentUserUseCase>(),
      getSchoolsUseCase: sl<GetSchoolsUseCase>(),
    ),
  );
  sl.registerFactory<EditProfileCubit>(
    () => EditProfileCubit(updateProfileUseCase: sl<UpdateProfileUseCase>()),
  );
  sl.registerFactory<ChangePasswordCubit>(
    () => ChangePasswordCubit(changePasswordUseCase: sl<ChangePasswordUseCase>()),
  );
}

void _registerProgressFeature() {
  sl.registerLazySingleton<ProgressRemoteDataSource>(
    () => ProgressRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ProgressLocalDataSource>(
    () => ProgressLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(
      remoteDataSource: sl<ProgressRemoteDataSource>(),
      localDataSource: sl<ProgressLocalDataSource>(),
      tokenStorage: sl<SecureTokenStorage>(),
    ),
  );
  sl.registerFactory<GetProgressUseCase>(
      () => GetProgressUseCase(sl<ProgressRepository>()));
  sl.registerFactory<SaveProgressUseCase>(
      () => SaveProgressUseCase(sl<ProgressRepository>()));
  sl.registerFactory<MarkLessonCompletedUseCase>(
      () => MarkLessonCompletedUseCase(sl<ProgressRepository>()));
  sl.registerFactory<AddQuizScoreUseCase>(
      () => AddQuizScoreUseCase(sl<ProgressRepository>()));
}
