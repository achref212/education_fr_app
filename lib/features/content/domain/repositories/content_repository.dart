import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/lesson.dart';
import '../entities/quiz_question.dart';
import '../entities/story.dart';

abstract class ContentRepository {
  Future<Either<Failure, Lesson>> getLesson(String lessonId);
  Future<Either<Failure, List<QuizQuestion>>> getQuizQuestions({
    String? level,
    String? category,
  });
  Future<Either<Failure, Story>> getStory(String storyId);
}
