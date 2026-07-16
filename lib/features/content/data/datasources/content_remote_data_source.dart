import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/lesson_model.dart';
import '../models/quiz_question_model.dart';
import '../models/story_model.dart';

abstract class ContentRemoteDataSource {
  Future<LessonModel> getLesson(String lessonId);
  Future<List<QuizQuestionModel>> getQuizQuestions({
    String? level,
    String? category,
  });
  Future<StoryModel> getStory(String storyId);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  ContentRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<LessonModel> getLesson(String lessonId) async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.lesson(lessonId));
    return LessonModel.fromJson(response.data!);
  }

  @override
  Future<List<QuizQuestionModel>> getQuizQuestions({
    String? level,
    String? category,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      ApiConstants.quizQuestions,
      queryParameters: <String, String?>{
        'level': level,
        'category': category,
      },
    );
    return response.data!
        .map(
          (dynamic item) =>
              QuizQuestionModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<StoryModel> getStory(String storyId) async {
    final response =
        await _dio.get<Map<String, dynamic>>(ApiConstants.story(storyId));
    return StoryModel.fromJson(response.data!);
  }
}
