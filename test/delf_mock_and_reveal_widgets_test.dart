import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/error/failures.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_section_submit_result.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_history.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_results.dart';
import 'package:education_fr_app/features/delf_test/domain/entities/delf_test_session.dart';
import 'package:education_fr_app/features/delf_test/domain/repositories/delf_test_repository.dart';
import 'package:education_fr_app/features/delf_test/domain/usecases/get_delf_results_use_case.dart';
import 'package:education_fr_app/features/student/data/datasources/student_remote_data_source.dart';
import 'package:education_fr_app/features/student/domain/entities/delf_mock_exam_models.dart';
import 'package:education_fr_app/features/student/domain/entities/student_models.dart';
import 'package:education_fr_app/features/student/presentation/pages/delf_mock_exam_list_screen.dart';
import 'package:education_fr_app/features/student/presentation/pages/personalized_parcours_reveal_screen.dart';
import 'package:education_fr_app/injection/injection_container.dart';

void main() {
  setUp(() async {
    await sl.reset();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('mock exam list shows published-empty state', (tester) async {
    sl.registerLazySingleton<StudentRemoteDataSource>(
      () => _FakeStudentDataSource(exams: const []),
    );

    await tester.pumpWidget(
      const MaterialApp(home: DelfMockExamListScreen()),
    );
    await tester.pump();

    expect(find.text('Aucun examen blanc publié'), findsOneWidget);
    expect(
      find.text(
          'Ton école n’a pas encore publié d’examen blanc pour le moment.'),
      findsOneWidget,
    );
  });

  testWidgets('personalized parcours reveal moves from loading to summary',
      (tester) async {
    sl.registerLazySingleton<StudentRemoteDataSource>(
      () => _FakeStudentDataSource(exams: const []),
    );
    sl.registerFactory<GetDelfResultsUseCase>(
      () => GetDelfResultsUseCase(_FakeDelfRepository()),
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: PersonalizedParcoursRevealScreen(sessionId: 'session-1'),
      ),
    );

    expect(
      find.text('Création de ton parcours personnalisé'),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    expect(find.text('Ton parcours est prêt'), findsOneWidget);
    expect(find.text('Ouvrir mon parcours'), findsOneWidget);
  });
}

class _FakeStudentDataSource implements StudentRemoteDataSource {
  _FakeStudentDataSource({required this.exams});

  final List<StudentDelfMockExam> exams;

  @override
  Future<List<StudentDelfMockExam>> getDelfMockExams() async => exams;

  @override
  Future<StudentHub> getHub() async => const StudentHub(
        firstName: 'Sana',
        lastName: 'Student',
        totalXp: 120,
        currentStreak: 3,
        longestStreak: 5,
        level: 2,
        completedSteps: 2,
        totalSteps: 8,
        parcoursPercent: 25,
        reviewOpenCount: 1,
        weakCategories: [StudentWeakCategory(category: 'Grammaire', count: 1)],
        achievementsPreview: [],
        nextAction: StudentNextAction(
          type: 'parcours',
          title: 'Réviser les accords',
          subtitle: 'Prochaine étape',
          route: 'parcours',
        ),
        nextStepTitle: 'Réviser les accords',
      );

  @override
  Future<StudentAchievements> getAchievements() => throw UnimplementedError();

  @override
  Future<StudentDelfMockAttempt> createDelfMockAttempt(String examId) =>
      throw UnimplementedError();

  @override
  Future<StudentReviewItem> completeReviewItem(String itemId) =>
      throw UnimplementedError();

  @override
  Future<StudentDelfMockExam> getDelfMockExam(String examId) =>
      throw UnimplementedError();

  @override
  Future<StudentDelfMockAttempt> getDelfMockAttempt(String attemptId) =>
      throw UnimplementedError();

  @override
  Future<StudentLeaderboard> getLeaderboard(String scope) =>
      throw UnimplementedError();

  @override
  Future<StudentReview> getReview() => throw UnimplementedError();

  @override
  Future<StudentHint> getReviewHint(String itemId) =>
      throw UnimplementedError();

  @override
  Future<StudentDelfMockAttempt> submitDelfMockAttempt({
    required String attemptId,
    required List<StudentDelfMockAnswer> answers,
  }) =>
      throw UnimplementedError();
}

class _FakeDelfRepository implements DelfTestRepository {
  @override
  Future<Either<Failure, DelfTestResults>> getResults(String sessionId) async =>
      const Right(
        DelfTestResults(
          sessionId: 'session-1',
          classLevel: '6eme',
          targetDelfLevel: 'A1',
          achievedDelfLevel: 'A1',
          overallScore: 72,
          categoryScores: {'Grammaire': 55, 'Vocabulaire': 80},
          comparisonToTarget: 'on_track',
          status: 'completed',
          parcoursAssignmentStatus: 'matched',
        ),
      );

  @override
  Future<Either<Failure, DelfTestSession?>> getActiveTest() =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, List<DelfTestHistory>>> getHistory() =>
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

  @override
  Future<Either<Failure, DelfTestResults>> finishTest(String sessionId) =>
      throw UnimplementedError();
}
