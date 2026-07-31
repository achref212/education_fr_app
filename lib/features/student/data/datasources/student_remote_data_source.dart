import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/entities/delf_mock_exam_models.dart';
import '../../domain/entities/student_models.dart';

abstract class StudentRemoteDataSource {
  Future<StudentHub> getHub();
  Future<StudentReview> getReview();
  Future<StudentReviewItem> completeReviewItem(String itemId);
  Future<StudentHint> getReviewHint(String itemId);
  Future<StudentLeaderboard> getLeaderboard(String scope);
  Future<StudentAchievements> getAchievements();
  Future<List<StudentDelfMockExam>> getDelfMockExams({
    String? classLevel,
    String? level,
  });
  Future<StudentDelfMockExam> getDelfMockExam(String examId);
  Future<StudentDelfMockAttempt> createDelfMockAttempt(String examId);
  Future<StudentDelfMockAttempt> getDelfMockAttempt(String attemptId);
  Future<StudentDelfMockAttempt> submitDelfMockAttempt({
    required String attemptId,
    required List<StudentDelfMockAnswer> answers,
  });
  Future<List<MultiplayerStudent>> getClassmates();
  Future<List<MultiplayerRoomRequest>> getMultiplayerRequests();
  Future<MultiplayerRoomRequest> createMultiplayerRequest({
    required List<String> participantIds,
    String? message,
  });
  Future<List<MultiplayerGame>> getMultiplayerGames();
  Future<List<MultiplayerRoom>> getMyMultiplayerRooms();
  Future<MultiplayerRoom> joinMultiplayerRoom(String roomCode);
  Future<MultiplayerRoomDetail> getMultiplayerRoom(String roomId);
  Future<MultiplayerSessionStart> startMultiplayerSession({
    required String roomId,
    required String gameSlug,
    required String difficulty,
  });
  Future<MultiplayerSessionState> getMultiplayerSession(String sessionId);
  Future<MultiplayerAnswerResult> submitMultiplayerAnswer({
    required String sessionId,
    required String questionId,
    required int selectedIndex,
    required int timeMs,
  });
  Future<MultiplayerSessionResults> getMultiplayerResults(String sessionId);
}

class StudentRemoteDataSourceImpl implements StudentRemoteDataSource {
  StudentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<StudentHub> getHub() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.studentHub);
    return StudentHub.fromJson(response.data!);
  }

  @override
  Future<StudentReview> getReview() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.studentReview);
    return StudentReview.fromJson(response.data!);
  }

  @override
  Future<StudentReviewItem> completeReviewItem(String itemId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentReviewComplete(itemId),
    );
    return StudentReviewItem.fromJson(response.data!);
  }

  @override
  Future<StudentHint> getReviewHint(String itemId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentReviewHint(itemId),
    );
    return StudentHint.fromJson(response.data!);
  }

  @override
  Future<StudentLeaderboard> getLeaderboard(String scope) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.studentLeaderboard,
      queryParameters: <String, String>{'scope': scope},
    );
    return StudentLeaderboard.fromJson(response.data!);
  }

  @override
  Future<StudentAchievements> getAchievements() async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.studentAchievements);
    return StudentAchievements.fromJson(response.data!);
  }

  @override
  Future<List<StudentDelfMockExam>> getDelfMockExams({
    String? classLevel,
    String? level,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConstants.studentDelfMockExams,
      queryParameters: <String, String>{
        if (classLevel != null && classLevel.isNotEmpty)
          'classLevel': classLevel,
        if (level != null && level.isNotEmpty) 'level': level,
      },
    );
    return response.data!
        .map(
          (dynamic item) =>
              StudentDelfMockExam.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<StudentDelfMockExam> getDelfMockExam(String examId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.studentDelfMockExam(examId),
    );
    return StudentDelfMockExam.fromJson(response.data!);
  }

  @override
  Future<StudentDelfMockAttempt> createDelfMockAttempt(String examId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentDelfMockExamAttempts(examId),
    );
    return StudentDelfMockAttempt.fromJson(response.data!);
  }

  @override
  Future<StudentDelfMockAttempt> getDelfMockAttempt(String attemptId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.studentDelfMockAttempt(attemptId),
    );
    return StudentDelfMockAttempt.fromJson(response.data!);
  }

  @override
  Future<StudentDelfMockAttempt> submitDelfMockAttempt({
    required String attemptId,
    required List<StudentDelfMockAnswer> answers,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentDelfMockAttemptSubmit(attemptId),
      data: <String, dynamic>{
        'answers': answers
            .map((StudentDelfMockAnswer answer) => answer.toJson())
            .toList(),
      },
      options: Options(receiveTimeout: const Duration(seconds: 70)),
    );
    return StudentDelfMockAttempt.fromJson(response.data!);
  }

  @override
  Future<List<MultiplayerStudent>> getClassmates() async {
    final response =
        await _dio.get<List<dynamic>>(ApiConstants.studentClassmates);
    return response.data!
        .map((dynamic item) =>
            MultiplayerStudent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MultiplayerRoomRequest>> getMultiplayerRequests() async {
    final response =
        await _dio.get<List<dynamic>>(ApiConstants.studentMultiplayerRequests);
    return response.data!
        .map((dynamic item) =>
            MultiplayerRoomRequest.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MultiplayerRoomRequest> createMultiplayerRequest({
    required List<String> participantIds,
    String? message,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.studentMultiplayerRequests,
      data: <String, dynamic>{
        'participantIds': participantIds,
        if (message != null && message.trim().isNotEmpty)
          'message': message.trim(),
      },
    );
    return MultiplayerRoomRequest.fromJson(response.data!);
  }

  @override
  Future<List<MultiplayerGame>> getMultiplayerGames() async {
    final response = await _dio.get<List<dynamic>>(ApiConstants.multiplayerGames);
    return response.data!
        .map((dynamic item) =>
            MultiplayerGame.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MultiplayerRoom>> getMyMultiplayerRooms() async {
    final response =
        await _dio.get<List<dynamic>>(ApiConstants.multiplayerRoomsMine);
    return response.data!
        .map((dynamic item) =>
            MultiplayerRoom.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MultiplayerRoom> joinMultiplayerRoom(String roomCode) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.multiplayerJoin,
      data: <String, dynamic>{'roomCode': roomCode.trim().toUpperCase()},
    );
    return MultiplayerRoom.fromJson(response.data!);
  }

  @override
  Future<MultiplayerRoomDetail> getMultiplayerRoom(String roomId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.multiplayerRoom(roomId),
    );
    return MultiplayerRoomDetail.fromJson(response.data!);
  }

  @override
  Future<MultiplayerSessionStart> startMultiplayerSession({
    required String roomId,
    required String gameSlug,
    required String difficulty,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.multiplayerRoomSessions(roomId),
      data: <String, dynamic>{
        'gameSlug': gameSlug,
        'difficulty': difficulty,
      },
    );
    return MultiplayerSessionStart.fromJson(response.data!);
  }

  @override
  Future<MultiplayerSessionState> getMultiplayerSession(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.multiplayerSession(sessionId),
    );
    return MultiplayerSessionState.fromJson(response.data!);
  }

  @override
  Future<MultiplayerAnswerResult> submitMultiplayerAnswer({
    required String sessionId,
    required String questionId,
    required int selectedIndex,
    required int timeMs,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.multiplayerSessionAnswers(sessionId),
      data: <String, dynamic>{
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'timeMs': timeMs,
      },
    );
    return MultiplayerAnswerResult.fromJson(response.data!);
  }

  @override
  Future<MultiplayerSessionResults> getMultiplayerResults(String sessionId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.multiplayerSessionResults(sessionId),
    );
    return MultiplayerSessionResults.fromJson(response.data!);
  }
}
