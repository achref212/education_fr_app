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
import 'package:education_fr_app/features/student/presentation/pages/delf_mock_exam_attempt_screen.dart';
import 'package:education_fr_app/features/student/presentation/pages/delf_mock_exam_list_screen.dart';
import 'package:education_fr_app/features/student/presentation/pages/delf_mock_exam_result_screen.dart';
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

  testWidgets('mock exam attempt has no visible return control',
      (tester) async {
    sl.registerLazySingleton<StudentRemoteDataSource>(
      () => _FakeStudentDataSource(
        exams: const [],
        attempt: _mockAttempt(status: 'in_progress'),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(
          home: DelfMockExamAttemptScreen(attemptId: 'attempt-1')),
    );
    await tester.pump();

    expect(find.byTooltip('Back'), findsNothing);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
    expect(find.text('Quitter le test'), findsNothing);
    expect(find.text('Examen blanc'), findsOneWidget);
  });

  testWidgets('mock exam result shows parcours status and primary CTA',
      (tester) async {
    sl.registerLazySingleton<StudentRemoteDataSource>(
      () => _FakeStudentDataSource(
        exams: const [],
        attempt: _mockAttempt(status: 'completed', score: 72),
      ),
    );

    await tester.pumpWidget(
      const MaterialApp(home: DelfMockExamResultScreen(attemptId: 'attempt-1')),
    );
    await tester.pump();

    expect(find.text('Ton score estimé est d’environ 72/100'), findsOneWidget);
    expect(find.text('Priorités du parcours'), findsOneWidget);
    expect(find.text('Renforcement: Vocabulaire'), findsOneWidget);
    expect(find.text('Parcours DELF personnalisé'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Ouvrir mon parcours DELF'),
      120,
    );
    expect(find.text('Ouvrir mon parcours DELF'), findsOneWidget);
    expect(find.text('Retour à l’accueil'), findsNothing);
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
  _FakeStudentDataSource({required this.exams, this.attempt});

  final List<StudentDelfMockExam> exams;
  final StudentDelfMockAttempt? attempt;

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
      Future.value(attempt ?? _mockAttempt(status: 'in_progress'));

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

StudentDelfMockAttempt _mockAttempt({required String status, int? score}) {
  const exam = StudentDelfMockExam(
    id: 'exam-1',
    track: 'Junior',
    level: 'A1',
    title: 'Examen blanc A1',
    status: 'published',
    totalDurationMinutes: 60,
    totalPoints: 100,
    sections: [
      StudentDelfMockSection(
        id: 'section-1',
        examId: 'exam-1',
        sectionOrder: 1,
        sectionType: 'reading',
        title: 'Compréhension des écrits',
        durationMinutes: 15,
        points: 25,
        instructions: 'Lis puis réponds.',
        rubric: {},
        metadata: {},
        items: [
          StudentDelfMockItem(
            id: 'item-1',
            sectionId: 'section-1',
            itemOrder: 1,
            title: 'Question 1',
            prompt: 'Choisis la bonne réponse.',
            points: 25,
            content: {
              'options': ['A', 'B'],
            },
            answerKey: {},
            rubric: {},
            metadata: {},
          ),
        ],
      ),
    ],
    assets: [],
  );
  return StudentDelfMockAttempt(
    attemptId: 'attempt-1',
    examId: 'exam-1',
    status: status,
    answers: const [],
    sectionScores: score == null ? const {} : const {'reading': 8},
    approximate: true,
    startedAt: '2026-01-01T00:00:00Z',
    exam: exam,
    overallScore: score,
    resultMessage:
        score == null ? null : 'Ton score estimé est d’environ $score/100',
    finishedAt: score == null ? null : '2026-01-01T00:10:00Z',
    assignedLearningPathId: score == null ? null : 'path-1',
    parcoursGeneratedByAi: score == null ? null : true,
    parcoursAssignmentStatus: score == null ? null : 'ai_generated',
    weakSkills: score == null
        ? const []
        : const [
            StudentDelfMockWeakSkill(
              sectionType: 'reading',
              title: 'Compréhension des écrits',
              score: 8,
              points: 25,
              percent: 32,
              practiceCategory: 'Vocabulaire',
            ),
          ],
  );
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
