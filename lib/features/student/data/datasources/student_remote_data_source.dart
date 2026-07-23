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
  Future<List<StudentDelfMockExam>> getDelfMockExams();
  Future<StudentDelfMockExam> getDelfMockExam(String examId);
  Future<StudentDelfMockAttempt> createDelfMockAttempt(String examId);
  Future<StudentDelfMockAttempt> getDelfMockAttempt(String attemptId);
  Future<StudentDelfMockAttempt> submitDelfMockAttempt({
    required String attemptId,
    required List<StudentDelfMockAnswer> answers,
  });
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
  Future<List<StudentDelfMockExam>> getDelfMockExams() async {
    final response =
        await _dio.get<List<dynamic>>(ApiConstants.studentDelfMockExams);
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
    );
    return StudentDelfMockAttempt.fromJson(response.data!);
  }
}
