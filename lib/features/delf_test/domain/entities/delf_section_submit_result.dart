import 'package:equatable/equatable.dart';

class DelfSectionSubmitResult extends Equatable {
  const DelfSectionSubmitResult({
    required this.sessionId,
    required this.category,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.submittedCategories,
    required this.remainingCategories,
  });

  final String sessionId;
  final String category;
  final int score;
  final int correctCount;
  final int totalQuestions;
  final List<String> submittedCategories;
  final List<String> remainingCategories;

  @override
  List<Object?> get props => [
        sessionId,
        category,
        score,
        correctCount,
        totalQuestions,
        submittedCategories,
        remainingCategories,
      ];
}
