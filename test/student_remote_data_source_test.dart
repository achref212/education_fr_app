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
    final exams = await dataSource.getDelfMockExams(
      classLevel: '6ème année',
      level: 'A1',
    );
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
    final classmates = await dataSource.getClassmates();
    final roomRequests = await dataSource.getMultiplayerRequests();
    final createdRequest = await dataSource.createMultiplayerRequest(
      participantIds: const ['student-1', 'student-2'],
      message: 'On veut jouer ensemble.',
    );
    final games = await dataSource.getMultiplayerGames();
    final rooms = await dataSource.getMyMultiplayerRooms();
    final joinedRoom = await dataSource.joinMultiplayerRoom('abcd');
    final room = await dataSource.getMultiplayerRoom('room-1');
    final started = await dataSource.startMultiplayerSession(
      roomId: 'room-1',
      gameSlug: 'quiz',
      difficulty: 'medium',
    );
    final session = await dataSource.getMultiplayerSession('session-1');
    final answer = await dataSource.submitMultiplayerAnswer(
      sessionId: 'session-1',
      questionId: 'question-1',
      selectedIndex: 0,
      timeMs: 1200,
    );
    final results = await dataSource.getMultiplayerResults('session-1');

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
    expect(submitted.assignedLearningPathId, 'path-1');
    expect(submitted.parcoursGeneratedByAi, isTrue);
    expect(submitted.parcoursAssignmentStatus, 'ai_generated');
    expect(submitted.weakSkills.single.practiceCategory, 'Vocabulaire');
    expect(classmates.single.gender, 'female');
    expect(roomRequests.single.status, 'pending');
    expect(createdRequest.message, 'On veut jouer ensemble.');
    expect(games.single.slug, 'quiz');
    expect(rooms.single.roomCode, 'ABCD');
    expect(joinedRoom.id, 'room-1');
    expect(room.participants.single.firstName, 'Sana');
    expect(started.session.id, 'session-1');
    expect(session.currentQuestion?.options, ['A', 'B']);
    expect(answer.points, 120);
    expect(results.myResult?.rank, 1);
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
        ApiConstants.studentClassmates,
        ApiConstants.studentMultiplayerRequests,
        ApiConstants.studentMultiplayerRequests,
        ApiConstants.multiplayerGames,
        ApiConstants.multiplayerRoomsMine,
        ApiConstants.multiplayerJoin,
        ApiConstants.multiplayerRoom('room-1'),
        ApiConstants.multiplayerRoomSessions('room-1'),
        ApiConstants.multiplayerSession('session-1'),
        ApiConstants.multiplayerSessionAnswers('session-1'),
        ApiConstants.multiplayerSessionResults('session-1'),
      ],
    );
    expect(requests[1].queryParameters['scope'], 'class');
    expect(requests[6].queryParameters['classLevel'], '6ème année');
    expect(requests[6].queryParameters['level'], 'A1');
    expect(requests[10].receiveTimeout, const Duration(seconds: 70));
    expect(requests[13].data['participantIds'], ['student-1', 'student-2']);
    expect(requests[16].data['roomCode'], 'ABCD');
    expect(requests[18].data['gameSlug'], 'quiz');
    expect(requests[20].data['selectedIndex'], 0);
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
  if (options.path == ApiConstants.studentClassmates) {
    return [_student()];
  }
  if (options.path == ApiConstants.studentMultiplayerRequests) {
    if (options.method == 'POST') {
      expect(options.data['participantIds'], ['student-1', 'student-2']);
      return _roomRequest(message: options.data['message'] as String?);
    }
    return [_roomRequest()];
  }
  if (options.path == ApiConstants.multiplayerGames) {
    return [
      {
        'id': 'game-1',
        'slug': 'quiz',
        'name': 'Quiz rapide',
        'description': 'Défi',
        'minPlayers': 2,
        'maxPlayers': 8,
        'defaultQuestionCount': 10,
      }
    ];
  }
  if (options.path == ApiConstants.multiplayerRoomsMine) {
    return [_room()];
  }
  if (options.path == ApiConstants.multiplayerJoin) {
    return _room();
  }
  if (options.path == ApiConstants.multiplayerRoom('room-1')) {
    return {
      ..._room(),
      'participants': [_student()],
      'session': _session(),
    };
  }
  if (options.path == ApiConstants.multiplayerRoomSessions('room-1')) {
    return {
      'session': _session(),
      'questions': [_question()],
      'settings': {},
    };
  }
  if (options.path == ApiConstants.multiplayerSession('session-1')) {
    return {
      'session': _session(),
      'leaderboard': [_leaderboardEntry()],
      'currentQuestion': _question(),
    };
  }
  if (options.path == ApiConstants.multiplayerSessionAnswers('session-1')) {
    return {
      'isCorrect': true,
      'points': 120,
      'totalScore': 120,
      'roundResult': {'correctIndex': 0, 'explanation': 'Bien joué.'},
    };
  }
  if (options.path == ApiConstants.multiplayerSessionResults('session-1')) {
    return {
      'session': _session(status: 'finished'),
      'leaderboard': [_leaderboardEntry()],
      'myResult': _leaderboardEntry(),
    };
  }
  throw StateError('Unexpected request ${options.path}');
}

Map<String, dynamic> _student() => {
      'id': 'student-1',
      'email': 'sana@example.com',
      'firstName': 'Sana',
      'lastName': 'Student',
      'classLevel': '6ème année',
      'gender': 'female',
      'profilePictureUrl': null,
    };

Map<String, dynamic> _roomRequest({String? message}) => {
      'id': 'request-1',
      'requesterId': 'student-1',
      'schoolId': 'school-1',
      'classLevel': '6ème année',
      'participantIds': ['student-1', 'student-2'],
      'participants': [_student()],
      'requester': _student(),
      'message': message,
      'status': 'pending',
      'createdRoomId': null,
      'rejectionReason': null,
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
      'reviewedAt': null,
    };

Map<String, dynamic> _room() => {
      'id': 'room-1',
      'roomCode': 'ABCD',
      'label': 'Quiz',
      'classLevel': '6ème année',
      'activeSessionId': 'session-1',
      'participantCount': 2,
      'data': {'status': 'waiting', 'classLevel': '6ème année'},
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-01T00:00:00Z',
    };

Map<String, dynamic> _session({String status = 'in_progress'}) => {
      'id': 'session-1',
      'roomId': 'room-1',
      'gameId': 'game-1',
      'difficulty': 'medium',
      'classLevel': '6ème année',
      'status': status,
      'currentRound': 1,
      'totalRounds': 1,
      'settings': {},
      'startedAt': '2026-01-01T00:00:00Z',
      'endedAt': null,
    };

Map<String, dynamic> _question() => {
      'id': 'question-1',
      'question': 'Choisis.',
      'options': ['A', 'B'],
      'round': 1,
      'totalRounds': 1,
    };

Map<String, dynamic> _leaderboardEntry() => {
      'userId': 'student-1',
      'firstName': 'Sana',
      'lastName': 'Student',
      'score': 120,
      'rank': 1,
      'finished': true,
    };

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
      'assignedLearningPathId': score == null ? null : 'path-1',
      'parcoursGeneratedByAi': score == null ? null : true,
      'parcoursAssignmentStatus': score == null ? null : 'ai_generated',
      'weakSkills': score == null
          ? []
          : [
              {
                'sectionType': 'reading',
                'title': 'Compréhension des écrits',
                'score': 8,
                'points': 25,
                'percent': 32,
                'practiceCategory': 'Vocabulaire',
              },
            ],
      'startedAt': '2026-01-01T00:00:00Z',
      'finishedAt': score == null ? null : '2026-01-01T00:10:00Z',
      'exam': _exam(),
    };
