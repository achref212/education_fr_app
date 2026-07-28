import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/error/failures.dart';
import 'package:education_fr_app/features/auth/domain/entities/profile_image_asset.dart';
import 'package:education_fr_app/features/auth/domain/entities/register_result.dart';
import 'package:education_fr_app/features/auth/domain/entities/school.dart';
import 'package:education_fr_app/features/auth/domain/entities/user.dart';
import 'package:education_fr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:education_fr_app/features/auth/domain/usecases/confirm_account_deletion_use_case.dart';
import 'package:education_fr_app/features/auth/domain/usecases/request_account_deletion_code_use_case.dart';
import 'package:education_fr_app/features/auth/domain/usecases/verify_account_deletion_password_use_case.dart';
import 'package:education_fr_app/features/profile/presentation/cubit/delete_account_cubit.dart';
import 'package:education_fr_app/features/profile/presentation/pages/account_deletion_password_recovery_screen.dart';
import 'package:education_fr_app/features/profile/presentation/pages/delete_account_screen.dart';
import 'package:education_fr_app/features/theme/domain/repositories/theme_repository.dart';
import 'package:education_fr_app/features/theme/domain/usecases/get_theme_mode_use_case.dart';
import 'package:education_fr_app/features/theme/domain/usecases/set_theme_mode_use_case.dart';
import 'package:education_fr_app/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:education_fr_app/injection/injection_container.dart';

void main() {
  setUp(() async {
    await sl.reset();
    final authRepository = _FakeAuthRepository();
    final themeRepository = _FakeThemeRepository();
    sl.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(
        getThemeMode: GetThemeModeUseCase(themeRepository),
        setThemeMode: SetThemeModeUseCase(themeRepository),
      ),
    );
    sl.registerFactory<DeleteAccountCubit>(
      () => DeleteAccountCubit(
        verifyPasswordUseCase:
            VerifyAccountDeletionPasswordUseCase(authRepository),
        requestCodeUseCase: RequestAccountDeletionCodeUseCase(authRepository),
        confirmDeletionUseCase: ConfirmAccountDeletionUseCase(authRepository),
      ),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('delete account screen shows password step and forgot link',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DeleteAccountScreen(user: _user()),
    ));

    expect(find.text('Supprimer mon compte'), findsOneWidget);
    expect(find.text('Mot de passe actuel'), findsOneWidget);
    expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('delete account screen moves from password to code step',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: DeleteAccountScreen(user: _user()),
    ));

    await tester.enterText(find.byType(TextFormField).first, 'secret-pass');
    await tester.tap(find.text('Continuer'));
    await tester.pump();

    expect(find.text('Confirmer la demande'), findsOneWidget);
    expect(find.text('Oui, envoyer le code'), findsOneWidget);

    await tester.tap(find.text('Oui, envoyer le code'));
    await tester.pump();

    expect(find.text('Code de suppression'), findsOneWidget);
    expect(find.text('Supprimer définitivement'), findsOneWidget);
  });

  testWidgets('account deletion recovery pre-fills logged-in user email',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AccountDeletionPasswordRecoveryScreen(
        email: 'student@example.com',
      ),
    ));

    expect(find.text('Réinitialiser le mot de passe'), findsOneWidget);
    expect(find.text('Adresse e-mail du compte'), findsOneWidget);
    expect(find.text('student@example.com'), findsOneWidget);
    expect(find.text('Envoyer le code'), findsOneWidget);
  });
}

User _user() => User(
      id: 'user-1',
      email: 'student@example.com',
      firstName: 'Sana',
      lastName: 'Student',
      level: 'B1',
      createdAt: DateTime(2026, 7, 28),
    );

class _FakeThemeRepository implements ThemeRepository {
  ThemeMode mode = ThemeMode.light;

  @override
  Future<ThemeMode> getThemeMode() async => mode;

  @override
  Future<void> saveThemeMode(ThemeMode mode) async {
    this.mode = mode;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, String>> verifyAccountDeletionPassword({
    required String password,
  }) async =>
      const Right('session-token');

  @override
  Future<Either<Failure, String>> requestAccountDeletionCode({
    required String deletionSessionToken,
  }) async =>
      const Right('state-token');

  @override
  Future<Either<Failure, Unit>> confirmAccountDeletion({
    required String deletionStateToken,
    required String code,
  }) async =>
      const Right(unit);

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String?>> forgotPassword({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, User>> getCurrentUser() => throw UnimplementedError();

  @override
  Future<Either<Failure, List<School>>> getSchools() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<ProfileImageAsset>>> listProfileImages() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> generateProfileAvatar({
    required String style,
    required Map<String, dynamic> customization,
    String? prompt,
    List<int>? selfieBytes,
    String? selfieFilename,
    String? selfieContentType,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, RegisterResult>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String classLevel,
    String? schoolId,
    required String phone,
    required DateTime dateOfBirth,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String?>> resendActivation({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? profilePictureUrl,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> uploadProfilePicture({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, User>> verifyRegistration({
    required String email,
    required String code,
    required String registrationStateToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String>> verifyResetCode({
    required String email,
    required String code,
    required String resetStateToken,
  }) =>
      throw UnimplementedError();
}
