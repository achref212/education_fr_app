import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/storage/secure_token_storage.dart';
import '../features/auth/data/datasources/auth_remote_data_source.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/forgot_password_use_case.dart';
import '../features/auth/domain/usecases/generate_profile_avatar_use_case.dart';
import '../features/auth/domain/usecases/get_current_user_use_case.dart';
import '../features/auth/domain/usecases/get_schools_use_case.dart';
import '../features/auth/domain/usecases/login_use_case.dart';
import '../features/auth/domain/usecases/logout_use_case.dart';
import '../features/auth/domain/usecases/register_use_case.dart';
import '../features/auth/domain/usecases/resend_activation_use_case.dart';
import '../features/auth/domain/usecases/reset_password_use_case.dart';
import '../features/auth/domain/usecases/set_profile_picture_use_case.dart';
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
import '../core/navigation/post_auth_navigator.dart';
import '../features/parcours/data/datasources/parcours_remote_data_source.dart';
import '../features/parcours/data/repositories/parcours_repository_impl.dart';
import '../features/parcours/domain/repositories/parcours_repository.dart';
import '../features/parcours/domain/usecases/complete_step_use_case.dart';
import '../features/parcours/domain/usecases/get_parcours_summary_use_case.dart';
import '../features/parcours/domain/usecases/get_parcours_use_case.dart';
import '../features/parcours/domain/usecases/start_step_use_case.dart';
import '../features/parcours/domain/usecases/update_difficulty_use_case.dart';
import '../features/parcours/presentation/cubit/parcours_cubit.dart';
import '../features/parcours/presentation/cubit/step_player_cubit.dart';
import '../features/content/data/datasources/content_remote_data_source.dart';
import '../features/content/data/repositories/content_repository_impl.dart';
import '../features/content/domain/repositories/content_repository.dart';
import '../features/content/domain/usecases/get_lesson_use_case.dart';
import '../features/content/domain/usecases/get_quiz_questions_use_case.dart';
import '../features/content/domain/usecases/get_story_use_case.dart';
import '../features/delf_test/data/datasources/delf_test_remote_data_source.dart';
import '../features/delf_test/data/repositories/delf_test_repository_impl.dart';
import '../features/delf_test/domain/repositories/delf_test_repository.dart';
import '../features/delf_test/domain/usecases/finish_delf_test_use_case.dart';
import '../features/delf_test/domain/usecases/get_active_delf_test_use_case.dart';
import '../features/delf_test/domain/usecases/get_delf_history_use_case.dart';
import '../features/delf_test/domain/usecases/get_delf_results_use_case.dart';
import '../features/delf_test/domain/usecases/start_delf_test_use_case.dart';
import '../features/delf_test/domain/usecases/submit_delf_section_use_case.dart';
import '../features/delf_test/presentation/cubit/delf_test_cubit.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../features/student/data/datasources/student_remote_data_source.dart';

final GetIt sl = GetIt.instance;

Future<void> initializeDependencies() async {
  await _registerCore();
  _registerThemeFeature();
  _registerAuthFeature();
  _registerProfileFeature();
  _registerProgressFeature();
  _registerParcoursFeature();
  _registerContentFeature();
  _registerDelfTestFeature();
  _registerStudentFeature();
  _registerHomeFeature();
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
    () =>
        ForgotPasswordCubit(forgotPasswordUseCase: sl<ForgotPasswordUseCase>()),
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
  sl.registerFactory<SetProfilePictureUseCase>(
      () => SetProfilePictureUseCase(sl<AuthRepository>()));
  sl.registerFactory<GenerateProfileAvatarUseCase>(
      () => GenerateProfileAvatarUseCase(sl<AuthRepository>()));
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
    () =>
        ChangePasswordCubit(changePasswordUseCase: sl<ChangePasswordUseCase>()),
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

void _registerParcoursFeature() {
  sl.registerLazySingleton<ParcoursRemoteDataSource>(
    () => ParcoursRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ParcoursRepository>(
    () => ParcoursRepositoryImpl(
        remoteDataSource: sl<ParcoursRemoteDataSource>()),
  );
  sl.registerFactory<GetParcoursUseCase>(
      () => GetParcoursUseCase(sl<ParcoursRepository>()));
  sl.registerFactory<GetParcoursSummaryUseCase>(
      () => GetParcoursSummaryUseCase(sl<ParcoursRepository>()));
  sl.registerFactory<StartStepUseCase>(
      () => StartStepUseCase(sl<ParcoursRepository>()));
  sl.registerFactory<CompleteStepUseCase>(
      () => CompleteStepUseCase(sl<ParcoursRepository>()));
  sl.registerFactory<UpdateDifficultyUseCase>(
      () => UpdateDifficultyUseCase(sl<ParcoursRepository>()));
  sl.registerFactory<ParcoursCubit>(
    () => ParcoursCubit(
      getParcours: sl<GetParcoursUseCase>(),
      updateDifficulty: sl<UpdateDifficultyUseCase>(),
    ),
  );
  sl.registerFactory<StepPlayerCubit>(
    () => StepPlayerCubit(
      getParcours: sl<GetParcoursUseCase>(),
      startStep: sl<StartStepUseCase>(),
      completeStep: sl<CompleteStepUseCase>(),
      getLesson: sl<GetLessonUseCase>(),
      getQuizQuestions: sl<GetQuizQuestionsUseCase>(),
      getStory: sl<GetStoryUseCase>(),
    ),
  );
}

void _registerContentFeature() {
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<ContentRepository>(
    () =>
        ContentRepositoryImpl(remoteDataSource: sl<ContentRemoteDataSource>()),
  );
  sl.registerFactory<GetLessonUseCase>(
      () => GetLessonUseCase(sl<ContentRepository>()));
  sl.registerFactory<GetQuizQuestionsUseCase>(
      () => GetQuizQuestionsUseCase(sl<ContentRepository>()));
  sl.registerFactory<GetStoryUseCase>(
      () => GetStoryUseCase(sl<ContentRepository>()));
}

void _registerDelfTestFeature() {
  sl.registerLazySingleton<DelfTestRemoteDataSource>(
    () => DelfTestRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<DelfTestRepository>(
    () => DelfTestRepositoryImpl(
        remoteDataSource: sl<DelfTestRemoteDataSource>()),
  );
  sl.registerFactory<StartDelfTestUseCase>(
      () => StartDelfTestUseCase(sl<DelfTestRepository>()));
  sl.registerFactory<GetActiveDelfTestUseCase>(
      () => GetActiveDelfTestUseCase(sl<DelfTestRepository>()));
  sl.registerFactory<GetDelfHistoryUseCase>(
      () => GetDelfHistoryUseCase(sl<DelfTestRepository>()));
  sl.registerFactory<SubmitDelfSectionUseCase>(
      () => SubmitDelfSectionUseCase(sl<DelfTestRepository>()));
  sl.registerFactory<FinishDelfTestUseCase>(
      () => FinishDelfTestUseCase(sl<DelfTestRepository>()));
  sl.registerFactory<GetDelfResultsUseCase>(
      () => GetDelfResultsUseCase(sl<DelfTestRepository>()));
  sl.registerLazySingleton<PostAuthNavigator>(
    () => PostAuthNavigator(
      getActiveDelfTest: sl<GetActiveDelfTestUseCase>(),
      getDelfHistory: sl<GetDelfHistoryUseCase>(),
    ),
  );
  sl.registerFactory<DelfTestCubit>(
    () => DelfTestCubit(
      startDelfTest: sl<StartDelfTestUseCase>(),
      getActiveDelfTest: sl<GetActiveDelfTestUseCase>(),
      submitDelfSection: sl<SubmitDelfSectionUseCase>(),
      finishDelfTest: sl<FinishDelfTestUseCase>(),
      getDelfResults: sl<GetDelfResultsUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
    ),
  );
}

void _registerStudentFeature() {
  sl.registerLazySingleton<StudentRemoteDataSource>(
    () => StudentRemoteDataSourceImpl(sl<Dio>()),
  );
}

void _registerHomeFeature() {
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      getParcoursSummary: sl<GetParcoursSummaryUseCase>(),
      getParcours: sl<GetParcoursUseCase>(),
    ),
  );
}
