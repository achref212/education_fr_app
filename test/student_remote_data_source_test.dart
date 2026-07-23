import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:education_fr_app/core/network/api_constants.dart';
import 'package:education_fr_app/features/student/data/datasources/student_remote_data_source.dart';
import 'package:education_fr_app/features/student/domain/entities/delf_mock_exam_models.dart';

void main() {
  test(
      'student data source calls hub leaderboard review achievements and hint endpoints',
      () async {
    final requests = <RequestOptions>[];
    final dio = Dio(BaseOptions(baseUrl: 'http://test'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          requests.add(options);
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 200,
              data: _responseFor(options),
            ),
          );
        },
      ),
    );

    final dataSource = StudentRemoteDataSourceImpl(dio);

    final hub = await dataSource.getHub();
    final leaderboard = await dataSource.getLeaderboard('class');
    final review = await dataSource.getReview();
    final hint = await dataSource.getReviewHint('review-1');
    final completed = await dataSource.completeReviewItem('review-1');
    final achievements = await dataSource.getAchievements();
    final exams = await dataSource.getDelfMockExams();
    final exam = await dataSource.getDelfMockExam('exam-1');
    final attempt = await dataSource.createDelfMockAttempt('exam-1');
    final loadedAttempt = await dataSource.getDelfMockAttempt('attempt-1');
    final submitted = await dataSource.submitDelfMockAttempt(
      attemptId: 'attempt-1',
      answers: const [
        StudentDelfMockAnswer(itemId: 'item-1', selectedIndex: 0),
        StudentDelfMockAnswer(itemId: 'item-2', text: 'Une réponse.'),
      ],
    );

    expect(hub.firstName, 'Sana');
    expect(leaderboard.currentRank, 1);
    expect(review.openItems.single.correctAnswer, 'Correct');
    expect(hint.source, 'fallback');
    expect(completed.status, 'completed');
    expect(achievements.items.single.unlocked, isTrue);
    expect(exams.single.title, 'Examen blanc A1');
    expect(exam.sections.single.items.single.options, ['A', 'B']);
    expect(attempt.status, 'in_progress');
    expect(loadedAttempt.exam.title, 'Examen blanc A1');
    expect(submitted.resultMessage, 'Ton score estimé est d’environ 75/100');
    expect(
      requests.map((request) => request.path),
      <String>[
        ApiConstants.studentHub,
        ApiConstants.studentLeaderboard,
        ApiConstants.studentReview,
        ApiConstants.studentReviewHint('review-1'),
        ApiConstants.studentReviewComplete('review-1'),
        ApiConstants.studentAchievements,
        ApiConstants.studentDelfMockExams,
        ApiConstants.studentDelfMockExam('exam-1'),
        ApiConstants.studentDelfMockExamAttempts('exam-1'),
        ApiConstants.studentDelfMockAttempt('attempt-1'),
        ApiConstants.studentDelfMockAttemptSubmit('attempt-1'),
      ],
    );
    expect(requests[1].queryParameters['scope'], 'class');
  });
}

dynamic _responseFor(RequestOptions options) {
  if (options.path == ApiConstants.studentHub) {
    return <String, dynamic>{
      'firstName': 'Sana',
      'lastName': 'Student',
      'classLevel': '6eme',
      'profilePictureUrl': '/media/avatar.png',
      'totalXp': 120,
      'currentStreak': 3,
      'longestStreak': 5,
      'level': 2,
      'completedSteps': 4,
      'totalSteps': 10,
      'parcoursPercent': 40,
      'nextStepId': 'step-1',
      'nextStepTitle': 'Réviser les accords',
      'reviewOpenCount': 1,
      'weakCategories': [
        {'category': 'Grammaire', 'count': 1},
      ],
      'recentDelf': null,
      'achievementsPreview': [
        _achievement(),
      ],
      'nextAction': {
        'type': 'review',
        'title': 'Réviser tes erreurs',
        'subtitle': '1 carte à terminer',
        'route': 'review',
      },
    };
  }
  if (options.path == ApiConstants.studentLeaderboard) {
    final entry = {
      'userId': 'student-1',
      'firstName': 'Sana',
      'lastName': 'Student',
      'classLevel': '6eme',
      'profilePictureUrl': null,
      'totalXp': 120,
      'currentStreak': 3,
      'completedSteps': 4,
      'progressPercent': 40,
      'rank': 1,
      'isCurrentUser': true,
    };
    return {
      'scope': 'class',
      'currentRank': 1,
      'currentStudent': entry,
      'entries': [entry]
    };
  }
  if (options.path == ApiConstants.studentReview) {
    return {
      'totalOpen': 1,
      'totalCompleted': 0,
      'weakCategories': [
        {'category': 'Grammaire', 'count': 1},
      ],
      'groups': [
        {
          'category': 'Grammaire',
          'total': 1,
          'openCount': 1,
          'items': [
            _reviewItem('open'),
          ],
        },
      ],
    };
  }
  if (options.path == ApiConstants.studentReviewHint('review-1')) {
    return {
      'itemId': 'review-1',
      'hint': 'Relis la règle.',
      'source': 'fallback'
    };
  }
  if (options.path == ApiConstants.studentReviewComplete('review-1')) {
    return _reviewItem('completed');
  }
  if (options.path == ApiConstants.studentAchievements) {
    return {
      'unlockedCount': 1,
      'totalCount': 1,
      'nextBadge': null,
      'items': [_achievement()],
    };
  }
  if (options.path == ApiConstants.studentDelfMockExams) {
    return [_exam(includeSections: false)];
  }
  if (options.path == ApiConstants.studentDelfMockExam('exam-1')) {
    return _exam();
  }
  if (options.path == ApiConstants.studentDelfMockExamAttempts('exam-1')) {
    return _attempt(status: 'in_progress');
  }
  if (options.path == ApiConstants.studentDelfMockAttempt('attempt-1')) {
    return _attempt(status: 'in_progress');
  }
  if (options.path == ApiConstants.studentDelfMockAttemptSubmit('attempt-1')) {
    expect(options.data['answers'], hasLength(2));
    return _attempt(status: 'completed', score: 75);
  }
  throw StateError('Unexpected request ${options.path}');
}

Map<String, dynamic> _reviewItem(String status) => {
      'id': 'review-1',
      'sourceType': 'parcours',
      'sourceId': 'step-1',
      'questionId': 'question-1',
      'category': 'Grammaire',
      'question': 'Question',
      'options': ['Wrong', 'Correct'],
      'selectedIndex': 0,
      'correctIndex': 1,
      'explanation': 'Explanation',
      'status': status,
      'timesReviewed': status == 'completed' ? 1 : 0,
    };

Map<String, dynamic> _achievement() => {
      'id': 'first_step',
      'title': 'Premier pas',
      'description': 'Terminer une étape.',
      'icon': 'flag',
      'unlocked': true,
      'progress': 1,
      'target': 1,
      'category': 'parcours',
    };

Map<String, dynamic> _exam({bool includeSections = true}) => {
      'id': 'exam-1',
      'track': 'Junior',
      'level': 'A1',
      'title': 'Examen blanc A1',
      'description': 'Préparation',
      'status': 'published',
      'totalDurationMinutes': 60,
      'totalPoints': 100,
      'sourceNotes': null,
      'sections': includeSections
          ? [
              {
                'id': 'section-1',
                'examId': 'exam-1',
                'sectionOrder': 1,
                'sectionType': 'listening',
                'title': 'Compréhension orale',
                'durationMinutes': 15,
                'points': 25,
                'instructions': 'Écoute et réponds.',
                'audioUrl': null,
                'rubric': {},
                'metadata': {},
                'items': [
                  {
                    'id': 'item-1',
                    'sectionId': 'section-1',
                    'itemOrder': 1,
                    'title': 'Question 1',
                    'prompt': 'Choisis.',
                    'points': 25,
                    'content': {
                      'options': ['A', 'B']
                    },
                    'answerKey': {'correctIndex': 0},
                    'rubric': {},
                    'metadata': {},
                  },
                ],
              }
            ]
          : [],
      'assets': [],
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
    };

Map<String, dynamic> _attempt({required String status, int? score}) => {
      'attemptId': 'attempt-1',
      'examId': 'exam-1',
      'status': status,
      'answers': [],
      'sectionScores': score == null ? {} : {'listening': score},
      'overallScore': score,
      'approximate': true,
      'resultMessage':
          score == null ? null : 'Ton score estimé est d’environ $score/100',
      'startedAt': '2026-01-01T00:00:00Z',
      'finishedAt': score == null ? null : '2026-01-01T00:10:00Z',
      'exam': _exam(),
    };
