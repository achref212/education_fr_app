import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/error/failures.dart';
import 'package:education_fr_app/features/auth/domain/entities/profile_image_asset.dart';
import 'package:education_fr_app/features/auth/domain/entities/register_result.dart';
import 'package:education_fr_app/features/auth/domain/entities/school.dart';
import 'package:education_fr_app/features/auth/domain/entities/user.dart';
import 'package:education_fr_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:education_fr_app/features/auth/domain/usecases/get_current_user_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_section_submit_result.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_history.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_results.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_session.dart';
import 'package:education_fr_app/features/delf_test/domain/repositories/delf_test_repository.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/finish_delf_test_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/get_active_delf_test_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/get_delf_history_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/get_delf_results_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/start_delf_test_use_case.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/submit_delf_section_use_case.dart';
import 'package:education_fr_app/features/delf_test/presentation/cubit/delf_test_cubit.dart';

void main() {
  test('loadActiveSession opens latest completed result when active is null',
      () async {
    final delfRepository = _FakeDelfRepository(
      history: const [
        DelfTestHistory(
          sessionId: 'session-1',
          classLevel: '6ème année',
          targetDelfLevel: 'A2',
          achievedDelfLevel: 'A2',
          overallScore: 86,
          categoryScores: {'Grammaire': 80},
          comparisonToTarget: 'Objectif atteint',
        ),
      ],
      results: const DelfTestResults(
        sessionId: 'session-1',
        classLevel: '6ème année',
        targetDelfLevel: 'A2',
        achievedDelfLevel: 'A2',
        overallScore: 86,
        categoryScores: {'Grammaire': 80},
        comparisonToTarget: 'Objectif atteint',
        status: 'completed',
      ),
    );
    final cubit = _buildCubit(delfRepository);

    await cubit.loadActiveSession();

    expect(
      cubit.state.maybeWhen(
        results: (result) => result.sessionId,
        orElse: () => null,
      ),
      'session-1',
    );
    expect(delfRepository.loadedResultSessionIds, ['session-1']);

    await cubit.close();
  });

  test(
      'loadActiveSession shows intro when there is no active or completed test',
      () async {
    final delfRepository = _FakeDelfRepository(history: const []);
    final cubit = _buildCubit(delfRepository);

    await cubit.loadActiveSession();

    expect(
      cubit.state.maybeWhen(
        intro: (classLevel, targetDelfLevel) => '$classLevel|$targetDelfLevel',
        orElse: () => null,
      ),
      '5ème année|A2',
    );

    await cubit.close();
  });
}

DelfTestCubit _buildCubit(_FakeDelfRepository delfRepository) {
  return DelfTestCubit(
    startDelfTest: StartDelfTestUseCase(delfRepository),
    getActiveDelfTest: GetActiveDelfTestUseCase(delfRepository),
    getDelfHistory: GetDelfHistoryUseCase(delfRepository),
    submitDelfSection: SubmitDelfSectionUseCase(delfRepository),
    finishDelfTest: FinishDelfTestUseCase(delfRepository),
    getDelfResults: GetDelfResultsUseCase(delfRepository),
    getCurrentUser: GetCurrentUserUseCase(_FakeAuthRepository()),
  );
}

class _FakeDelfRepository implements DelfTestRepository {
  _FakeDelfRepository({
    required this.history,
    this.results,
  });

  final List<DelfTestHistory> history;
  final DelfTestResults? results;
  final List<String> loadedResultSessionIds = [];

  @override
  Future<Either<Failure, DelfTestSession?>> getActiveTest() async =>
      const Right(null);

  @override
  Future<Either<Failure, List<DelfTestHistory>>> getHistory() async =>
      Right(history);

  @override
  Future<Either<Failure, DelfTestResults>> getResults(String sessionId) async {
    loadedResultSessionIds.add(sessionId);
    final result = results;
    if (result == null) {
      return const Left(ServerFailure('Résultat introuvable.'));
    }
    return Right(result);
  }

  @override
  Future<Either<Failure, DelfTestResults>> finishTest(String sessionId) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, DelfTestSession>> startTest() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, DelfSectionSubmitResult>> submitSection({
    required String sessionId,
    required String category,
    required List<DelfTestAnswer> answers,
  }) =>
      throw UnimplementedError();
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> getCurrentUser() async => Right(
        User(
          id: 'user-1',
          email: 'student@example.com',
          firstName: 'Sana',
          lastName: 'Student',
          level: '1',
          createdAt: DateTime(2026, 7, 27),
          classLevel: '5ème année',
        ),
      );

  @override
  Future<Either<Failure, Unit>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> confirmAccountDeletion({
    required String deletionStateToken,
    required String code,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, String?>> forgotPassword({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<School>>> getSchools() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<ProfileImageAsset>>> listProfileImages() async =>
      const Right([]);

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
  Future<Either<Failure, String>> requestAccountDeletionCode({
    required String deletionSessionToken,
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

  @override
  Future<Either<Failure, String>> verifyAccountDeletionPassword({
    required String password,
  }) =>
      throw UnimplementedError();
}
