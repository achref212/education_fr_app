import 'package:freezed_annotation/freezed_annotation.dart';

part 'progress.freezed.dart';

/// Tracks a student's learning progress across lessons, quizzes and exercises.
@freezed
class Progress with _$Progress {
  const factory Progress({
    @Default([]) List<String> lessonsCompleted,
    @Default({}) Map<String, List<int>> quizScores,
    @Default({}) Map<String, List<int>> exerciseScores,
  }) = _Progress;

  const Progress._();

  bool hasCompletedLesson(String lessonId) =>
      lessonsCompleted.contains(lessonId);

  double averageQuizScore(String category) {
    final scores = quizScores[category];
    if (scores == null || scores.isEmpty) return 0;
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  int get totalLessonsCompleted => lessonsCompleted.length;
}
